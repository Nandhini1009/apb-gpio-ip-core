`timescale 1ns/1ps

module aux_interface_tb;

    // Testbench signals
    reg sys_clk;
    reg sys_rst;
    reg [31:0] aux_in;
    wire [31:0] aux_i;

    // Instantiate the Unit Under Test (UUT)
    aux_interface uut (
        .sys_clk(sys_clk),
        .sys_rst(sys_rst),
        .aux_in(aux_in),
        .aux_i(aux_i)
    );

    // Clock generation: 10ns period → 100MHz
    initial begin
        sys_clk = 0;
        forever #5 sys_clk = ~sys_clk;
    end

    // Test stimulus
    initial begin
        // Initialize inputs
        sys_rst = 0;      // Start with reset active (active low)
        aux_in = 32'h00000000;

        // Hold reset for a while
        #20;
        sys_rst = 1;      // De-assert reset

        // Apply first data input
        #10;
        aux_in = 32'hA5A5A5A5;

        // Wait for a few clock cycles
        #20;
        aux_in = 32'h5A5A5A5A;

        // Apply another data input
        #20;

        // Assert reset again
        sys_rst = 0;
        #20;

        // De-assert reset and apply new data
        sys_rst = 1;
        aux_in = 32'hFFFFFFFF;

        #20;

        // Finish simulation
        $stop;
    end

endmodule

