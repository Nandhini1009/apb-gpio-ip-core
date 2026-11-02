`define RGPIO_IN 32'h0 
`define RGPIO_OUT 32'h4
`define RGPIO_OE 32'h8
`define RGPIO_INTE 32'hc
`define RGPIO_PTRIG 32'h10
`define RGPIO_AUX 32'h14
`define RGPIO_CTRL 32'h18
`define RGPIO_INTS 32'h1c
`define RGPIO_ECLK 32'h20 
`define RGPIO_NEC 32'h24
`define RGPIO_CTRL_INTE 1'b0
`define RGPIO_CTRL_INTS 1'b1

module GPIO_top_tb;
reg pclk, presetn, psel, penable,pwrite, ext_clk_pad_i;
reg [31:0] paddr, pwdata, aux_in;
wire [31:0] io_pad;
wire pready, irq;
wire [31:0] prdata;
reg io_dir=1;
reg [31:0] temp=32'bz;
GPIO_top DUT (pclk,presetn,psel, penable, pwrite,paddr, pwdata, aux_in, irq, pready, io_pad, ext_clk_pad_i, prdata);
//external clock
always
begin
#5 ext_clk_pad_i=1'b0;
#5 ext_clk_pad_i=1'b1;
end
 //apb_clock
always
begin
#10 pclk=1'b0;
#10 pclk=1'b1;
end
task initialise;
begin
{pclk, presetn, psel, penable, pwrite, paddr, pwdata, aux_in,ext_clk_pad_i}=0;
end
endtask
task reset;
begin
presetn=0;
@(negedge pclk);
@(negedge pclk);
presetn=1;
end
endtask
//Write into Register as per APB
task apb_write (input [31:0]addr, input [31:0]in);
begin
@(negedge pclk)
paddr=addr;
psel=1'b1;
pwrite=1'b1;
penable=1 'b0;
pwdata=in;
@(negedge pclk)
paddr=addr;
psel=1'b1;
pwrite=1'b1;
penable=1'b1;
pwdata=in;
@(negedge pclk)
@(negedge pclk)
paddr=addr;
psel=1'b1;
pwrite=1'b0;
penable=1'b1;
pwdata=in;
/* @(negedge pclk)
paddr=addr;
psel=1'b0;
pwrite=1'b0;
penable=1'b0;
pwdata=pwdata*/
 end
endtask
//Read from the registers as per the APB
task apb_read(input [31:0] addr);
begin
/* @(negedge pclk)
paddr=addr;
psel=1'b0;
pwrite=1'b0;
penable=1'b0; */
@(negedge pclk)
paddr=addr;
psel=1'b1;
pwrite=1'b0;
penable=1'b1;

@(negedge pclk)
paddr=addr;
psel=1'b1;
pwrite=1'b0;
penable=1'b1;
end
endtask
task aux_write(input [31:0]a);
begin
@(negedge pclk)
aux_in=a;
end
endtask

//io pad as inputs.
task io_pad_input([31:0]in_temp);
begin
io_dir=1'b0;
@(negedge ext_clk_pad_i)
temp=in_temp;
end
endtask

// io pad as Output
task io_pad_output;
begin
io_dir=1 'b1;
end
endtask
assign io_pad=~io_dir? temp: 32'bz;
initial
begin
initialise;
#10;
reset;
//General purpose as output
/* apb_write('GPIO_RGPIO_INTE, 32'h0);
apb_write('GPIO_RGPIO_OUT, 32'h56781234);
apb_write(`GPIO_RGPIO_OE, 32'hffffffff);
io pad_output;*/

// General purpose as Polled Input (system clock)
/* apb_write(RGPIO_OE, 32'h0);
apb_write('RGPIO_CTRL, 2'b00);
apb_write('RGPIO_INTE, 32?h0);
apb_write('RGPIO_ECLK, 32?h0);
io_pad_input(32'h12345678);
apb_read(`RGPIO_IN); */

//General purpose i/o driven by Auxiliary Input
/* aux_write(32'hf7f6f504);
apb_write('GPIO_RGPIO_AUX, 32'hffffffff);
apb_write('GPIO_RGPIO_OE, 32'hffffffff);
io_pad_output;
apb_write('GPIO_RGPIO_AUX, 32'h0); */


//General purpose i/o as Bi-directional i/o (system clock)
/* apb_write(`RGPIO_INTE, 32'h0);
apb_write('RGPIO_ECLK, 32?h0);
apb_write(`RGPIO_OUT, 32'h10203040);//output
apb_write(`RGPIO_OE, 32?hf0f0f0f0);
io_pad_input(32'hz5z1z0z9); //input
apb_read(`RGPIO_IN);  */

//General purpose i/o as input in Interrupt Mode (system clock)
io_pad_input(32'h0000ffff);
apb_write(`RGPIO_OE, 32'h0);
apb_write(`RGPIO_ECLK, 32'h0);
apb_write(`RGPIO_NEC, 32'h0);
apb_write(`RGPIO_CTRL, 2'b01);
apb_write(`RGPIO_PTRIG, 32'hffffffff); // Positive Edge
apb_write(`RGPIO_PTRIG, 32'h0); // Negative Edge
apb_write(`RGPIO_INTS, 32'h0000ff00);
apb_write(`RGPIO_INTE, 32'h000f00ff);
io_pad_input(32'hffff0000);
// apb_write('RGPIO_CTRL_INTE, 1'b1);
//apb_write('RGPIO_CTRL_INTS, 1'b1);
apb_read(`RGPIO_INTS);
end
endmodule
