module loop_counter (nStart, Step, Loops, Play);
    input nStart, Step;
    input [7:0] Loops; // Max 255 Loops
    output reg Play;

    reg [11:0] Q;
    reg [11:0] total_steps;
    reg done;
    always@(posedge Step, negedge nStart)
    begin
        if (!nStart)
        begin
            total_steps <= 16 * Loops; 
            Q <= 0;
            done <= 0;
            Play <= 1;
        end
        else if (!Loops) // loop infinitely when Loops == 0
        begin
            Play <= 1;
            done <= 0;
        end
        else if (!done)
        begin
            if (Q == total_steps - 1)
            begin
                Play <= 0;
                done <= 1;
            end
            else
            begin
                Q <= Q + 1;
                Play <= 1;
            end
        end
        else
        begin
            Play <= 0;
            done <= 1;
        end
    end
endmodule