module aux_interface (
    input wire         sys_clk,   // Clock signal
    input wire         sys_rst,   // Asynchronous active-low reset
    input wire [31:0]  aux_in,    // Input data
    output wire [31:0] aux_i      // Output data
);

    reg [31:0] register_out;

    // Register with asynchronous active-low reset
    always @(posedge sys_clk or negedge sys_rst) begin
        if (!sys_rst)                   // Active-low reset
            register_out <= 32'b0;      // Clear register
        else
            register_out <= aux_in;     // Load input into register
    end

    // MUX logic is not needed now because reset logic is built into the register
    assign aux_i = (!sys_rst) ? 32'b0 : register_out;

endmodule

