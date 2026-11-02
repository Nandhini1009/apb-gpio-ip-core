`timescale 1ns/1ps

module tb_io_interface;

// Testbench signals
reg  [31:0] out_pad_o_tb;
reg  [31:0] oen_padoe_o_tb;
wire [31:0] io_pad_tb;
wire [31:0] in_pad_i_tb;

// Internal signal to drive io_pad during input test
reg  [31:0] io_pad_driver;

// Instantiate the DUT (Device Under Test)
io_interface uut (
    .out_pad_o(out_pad_o_tb),
    .oen_padoe_o(oen_padoe_o_tb),
    .io_pad(io_pad_tb),
    .in_pad_i(in_pad_i_tb)
);

// Pullup / Pulldown model for bidirectional pad (simple driver for simulation)
assign io_pad_tb = (oen_padoe_o_tb == 32'hFFFFFFFF) ? io_pad_driver : 32'bz;

initial begin
    // Initial values
    out_pad_o_tb   = 32'd0;
    oen_padoe_o_tb = 32'hFFFFFFFF; // All inputs by default
    io_pad_driver  = 32'd0;

    $display("Starting IO Interface Test...");

    // ----------------------------
    // Test 1: Drive Output to Pads
    // ----------------------------
    #10;
    $display("Test 1: Output to Pads");
    out_pad_o_tb   = 32'hA5A5A5A5;    // Arbitrary output data
    oen_padoe_o_tb = 32'h00000000;    // All output enable low (output mode)

    #10;
    $display("Expected io_pad_tb = %h", out_pad_o_tb);
    $display("Observed io_pad_tb = %h", io_pad_tb);

    // ----------------------------
    // Test 2: Read Inputs from Pads
    // ----------------------------
    #10;
    $display("\nTest 2: Read from Pads");
    oen_padoe_o_tb = 32'hFFFFFFFF;    // All inputs (output disabled)
    io_pad_driver  = 32'h5A5A5A5A;    // Drive test input data

    #10;
    $display("Driven io_pad_driver = %h", io_pad_driver);
    $display("Read in_pad_i_tb      = %h", in_pad_i_tb);

    // ----------------------------
    // Test 3: Mixed IO Direction (half output, half input)
    // ----------------------------
    #10;
    $display("\nTest 3: Mixed IO directions");
    out_pad_o_tb   = 32'hFFFF0000;
    oen_padoe_o_tb = 32'h0000FFFF;    // Lower 16 bits = output, Upper 16 bits = input
    io_pad_driver  = 32'h12340000;    // Driving upper 16 bits only

    #10;
    $display("Expected io_pad lower 16 = %h", out_pad_o_tb[15:0]);
    $display("Expected io_pad upper 16 driven = %h", io_pad_driver[31:16]);
    $display("Read in_pad_i_tb = %h", in_pad_i_tb);

    #10;
    $display("\nTest Completed.");
    $finish;
end

endmodule

