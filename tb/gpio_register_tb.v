/*`define GPIO_RGPIO_INTE 32'h3 //Address 0x0c
`define GPIO_RGPIO_PTRIG 32'h4 //Address 0x10
`define GPIO_RGPIO_AUX 32'h5 //Address 0x14
`define GPIO_RGPIO_CTRL 32'h6 //Address 0x18
`define GPIO_RGPIO_INTS 32'h7 //Address 0x1c
`define GPIO_RGPIO_ECLK 32'h8 //Address 0x20
`define GPIO_RGPIO_NEC 32'h9 //Address 0x24
`define GPIO_RGPIO_CTRL_INTE 1'b0 //Address 0
`define GPIO_RGPIO_CTRL_INTS 1'b1 //Address 1*/

`define RGPIO_IN 32'h0
`define RGPIO_OUT 32'h4
`define RGPIO_OE 32'h8
`define RGPIO_INTE 32'hc
`define RGPIO_PTRIG 32'h10
`define RGPIO_AUX 32'h14
`define RGPIO_CTRL 32'h18
`define RGPIO_INTS 32'h1C
`define RGPIO_ECLK 32'h20
`define RGPIO_NEC 32'h24
`define RGPIO_CTRL_INTE 1'b0
`define RGPIO_CTRL_INTS 1'b1

//'include "gpio_defines.v"

module GPIO_register_tb();

reg sysclk, sysrst, gpio_we;
reg [31:0]gpio_addr;
reg [31:0] gpio_dat_i;
wire[31:0]gpio_dat_o;
wire gpio_inta_o;
reg [31:0] aux_i;
reg [31:0] in_pad_i;
reg gpio_eclk;
wire [31:0] out_pad_o;
wire [31:0] oen_padoe_o;

//DUT instantiation
GPIO_register DUT(.sysclk(sysclk), .sysrst(sysrst), .gpio_we(gpio_we), .gpio_addr(gpio_addr),
                   .gpio_dat_i(gpio_dat_i), .aux_i(aux_i), .in_pad_i(in_pad_i), .gpio_eclk(gpio_eclk),
                   .gpio_inta_o(gpio_inta_o), .gpio_dat_o(gpio_dat_o), .out_pad_o(out_pad_o),
                   .oen_padoe_o(oen_padoe_o));
// sysclk, sysrst, gpio_we, input [31:0]gpio_addr, gpio_dat_i, aux_i, input[31:0] in_pad_i, input gpio_eclk, output reg [31:0]gpio_dat_o, output out_pad_o, oen_padoe_o);

//Generation of sys_clk
initial
sysclk=0;
always #5 sysclk =~ sysclk;

//Generation of e_clk
initial
gpio_eclk=1'b0;
always #10 gpio_eclk =~ gpio_eclk;

//reset task
task reset;
begin
sysrst=1'b1;
#40;
sysrst=1'b0;
end
endtask

//initialize all inputs to zero
task initialize;
begin
gpio_addr=1'b0;
gpio_we=1'b0;
gpio_dat_i=1'b0;
in_pad_i=1'b0;
aux_i=1'b0;
end
endtask

//write into the register
task write(input[31:0] addr,input[31:0] aux);
begin @(negedge sysclk)
gpio_addr=addr;
gpio_we=1'b1;
gpio_dat_i=aux;
end
endtask

//read from the register
task read(input[31:0]addr);
begin
@(negedge sysclk)
gpio_addr=addr;
gpio_we=0;
end
endtask

//in_pad_i inputs
task in_pad_inputs();
begin
@(negedge gpio_eclk)
in_pad_i=$random;
end
endtask

//auxiliary inputs
task aux_inputs;
begin
aux_i=$random;
end
endtask

initial
begin
reset;
initialize;
#20;
repeat(2)
begin
aux_inputs;
#10;
in_pad_inputs;
#5;

write(`RGPIO_AUX,$random);
write(`RGPIO_INTS,$random);
write(`RGPIO_INTE,$random);
write(`RGPIO_OUT,$random);
write(`RGPIO_OE,$random);
write(`RGPIO_PTRIG,$random);
write(`RGPIO_ECLK,$random);
write(`RGPIO_NEC,$random);
write(`RGPIO_CTRL,$random);

#50;
read(`RGPIO_INTS);
read(`RGPIO_IN);
read(`RGPIO_AUX);
read(`RGPIO_INTE);
read(`RGPIO_OUT);
read(`RGPIO_OE);
read(`RGPIO_PTRIG);
read(`RGPIO_ECLK);
read(`RGPIO_NEC);
read(`RGPIO_CTRL);
write(`RGPIO_INTS,32'h0);
end
#400 $finish();
end
endmodule