module audio_interface (
	// Inputs
	CLOCK_50,
	KEY,
	SW,

	// Bidirectionals
	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,

	FPGA_I2C_SDAT,
	DAC_I2C_SDAT, // PIN_AC18, GPIO_0[0]

	// Outputs
	AUD_XCK,
	AUD_DACDAT,

	FPGA_I2C_SCLK,
	DAC_I2C_SCLK, // PIN_Y17,  GPIO_0[1]
	DAC_I2C_A0,   // PIN_AD17, GPIO_0[2]
	LEDR
);

	// Inputs
	input		   CLOCK_50;
	input	[1:0]	KEY;
	input	[9:0]	SW;

	// Bidirectionals
	inout		   AUD_BCLK;
	inout			AUD_ADCLRCK;
	inout			AUD_DACLRCK;

	inout			FPGA_I2C_SDAT;
	inout			DAC_I2C_SDAT;

	// Outputs
	output	   AUD_XCK;
	output	   AUD_DACDAT;

	output	   FPGA_I2C_SCLK;
	output      DAC_I2C_SCLK;
	output      DAC_I2C_A0;
	output [9:0] LEDR;

	// Internal Wires
	wire        audio_out_allowed;
	wire        write_audio_out;

	wire [11:0]  Select; // Tone select
	wire        Step;   // Step pulse
	wire        nStart; // Start playback
	wire [31:0]  BPM;    // Beats per minute
	wire [7:0]  Loops;  // Number of playback loops
	wire        Play;   // Playback enable
	wire [31:0] Out;    // Audio output

	// Internal Registers
	reg  [31:0] left_channel_audio_out;
	reg  [31:0] right_channel_audio_out;
	reg  [31:0] audio_signed;

	// Sequential Logic
	always@(posedge CLOCK_50) // Clock with 48kHz
	begin
		if (Play)
		begin
			// Sign extend to 32 bits
			left_channel_audio_out	<= Out;
			right_channel_audio_out <= Out;
			audio_signed            <= Out;
		end
		else
		begin
			left_channel_audio_out	<= 0;
			right_channel_audio_out <= 0;
			audio_signed            <= 0;
		end
	end

	// Combinational Logic
	assign A0 = 0;

	assign write_audio_out = audio_out_allowed;

	assign Select = {5'b0, SW[6:0]};
	assign nStart = KEY[1];
	assign BPM    = 32'd100;
	assign Loops  = {5'b0, SW[9:7]};

	assign LEDR[7:0] = Out[7:0];
	assign LEDR[9] = Step;
	assign LEDR[8] = Play;

	// Internal Modules
	BPM_counter B1 (
		.Clock  (CLOCK_50), 
		.nStart (nStart), 
		.BPM    (BPM), 
		.Step   (Step)
	);

	loop_counter L1 (
		.nReset (KEY[0]),
		.nStart (nStart), 
		.Step   (Step), 
		.Loops  (Loops), 
		.Play   (Play)
	);

	audio_generator A1 (
		.Clock  (CLOCK_50),
		.nStart (nStart),
		.Select (Select),
		.Out    (Out)
	);

	// ===================================================
// Add these signals at the top of audio_interface
// ===================================================

wire clk6_25MHz, clk3_12MHz, clk781kHz, clk195kHz;

wire clk_2x100kHz = clk195kHz;
wire clk_2x400kHz = clk781kHz;
wire clk_2x1_7MHz = clk3_12MHz;
wire clk_2x3_4MHz = clk6_25MHz;

// MCP4725 I2C tri-state interface
wire SCL_in  = DAC_I2C_SCLK;
wire SDA_in  = DAC_I2C_SDAT;

wire SCL_o;
wire SCL_t;
wire SDA_o;
wire SDA_t;

// Convert signed 32-bit audio to unsigned 12-bit DAC sample
wire [11:0] dac_sample = audio_signed[31] ? 12'd0 : audio_signed[31:20];


// ===================================================
// Clock generation for MCP4725
// ===================================================
clkGen100MHz_6_25MHz cg0 (
    .clk100MHz(CLOCK_50),
    .rst(~KEY[0]),
    .clk6_25MHz(clk6_25MHz)
);

clkGenclk6_25MHz_3_12MHz cg1 (
    .clk6_25MHz(clk6_25MHz),
    .rst(~KEY[0]),
    .clk3_12MHz(clk3_12MHz)
);

clkGen3_12MHz_781kHz cg2 (
    .clk3_12MHz(clk3_12MHz),
    .rst(~KEY[0]),
    .clk781kHz(clk781kHz)
);

clkGen_781kHz_195kHz cg3 (
    .clk781kHz(clk781kHz),
    .rst(~KEY[0]),
    .clk195kHz(clk195kHz)
);


// ===================================================
// MCP4725 DAC — replaces the old DAC_controller
// ===================================================
mcp4725 dac0 (
    .clk            (CLOCK_50),
    .rst            (~KEY[0]),

    // I2C lines
    .SCL_i          (SCL_in),
    .SCL_o          (SCL_o),
    .SCL_t          (SCL_t),
    .SDA_i          (SDA_in),
    .SDA_o          (SDA_o),
    .SDA_t          (SDA_t),

    // DAC sample
    .data_i         (dac_sample),
    .data_reg       (),
    .enable         (audio_out_allowed),
    .mode_i         (2'b00),
    .mode_reg       (),

    // EEPROM unused
    .writeToMem     (1'b0),
    .readFromMem    (1'b0),

    // 400 kHz I2C
    .i2cSpeed       (2'b01),
    .A0             (DAC_I2C_A0),

    // High-speed clocks
    .clk_2x100kHz   (clk_2x100kHz),
    .clk_2x400kHz   (clk_2x400kHz),
    .clk_2x1_7MHz   (clk_2x1_7MHz),
    .clk_2x3_4MHz   (clk_2x3_4MHz)
);


// ===================================================
// I2C open-drain top-level output wiring
// ===================================================
assign DAC_I2C_SCLK = SCL_t ? 1'bz : SCL_o;
assign DAC_I2C_SDAT = SDA_t ? 1'bz : SDA_o;
assign DAC_I2C_A0   = 1'b0;


	Audio_Controller AC1 (
		// Inputs
		.CLOCK_50				    (CLOCK_50),
		.reset						 (~KEY[0]),

		.clear_audio_in_memory	 (),
		.read_audio_in				 (),
		
		.clear_audio_out_memory	 (),
		.left_channel_audio_out	 (left_channel_audio_out),
		.right_channel_audio_out (right_channel_audio_out),
		.write_audio_out			 (write_audio_out),

		.AUD_ADCDAT					 (),

		// Bidirectionals
		.AUD_BCLK					 (AUD_BCLK),
		.AUD_ADCLRCK				 (AUD_ADCLRCK),
		.AUD_DACLRCK				 (AUD_DACLRCK),

		// Outputs
		.audio_in_available		 (),
		.left_channel_audio_in	 (),
		.right_channel_audio_in	 (),

		.audio_out_allowed		 (audio_out_allowed),

		.AUD_XCK					    (AUD_XCK),
		.AUD_DACDAT					 (AUD_DACDAT)
	);

	avconf #(.USE_MIC_INPUT(1)) AVC1 (
		.FPGA_I2C_SCLK (FPGA_I2C_SCLK),
		.FPGA_I2C_SDAT (FPGA_I2C_SDAT),
		.CLOCK_50      (CLOCK_50),
		.reset		   (~KEY[0])
	);

endmodule