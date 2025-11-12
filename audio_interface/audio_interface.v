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

	DAC_controller DC1 (
			// Host side
			.CLOCK_50         (Clock),
			.reset            (~nReset),
			.audio_in_signed  (audio_signed),
			//	I2C Side
			.DAC_I2C_SCLK     (DAC_I2C_SCLK),
			.DAC_I2C_SDAT	   (DAC_I2C_SDAT)
	);

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