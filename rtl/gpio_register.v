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

module GPIO_register(input sysclk, sysrst, gpio_we, input [31:0]gpio_addr,gpio_dat_i, aux_i, input[31:0] in_pad_i, input gpio_eclk, output gpio_inta_o, output reg [31:0]gpio_dat_o, output [31:0] out_pad_o, oen_padoe_o);

reg [31:0]rgpio_in;
reg [31:0] rgpio_out;
reg [31:0] rgpio_oe;
reg [31:0]rgpio_inte;
reg [31:0]rgpio_ptrig;
reg [31:0] rgpio_aux;
reg [31:0] rgpio_ints;
reg [31:0] rgpio_eclk;
reg [31:0] rgpio_nec;
reg [1:0] rgpio_ctrl;
reg [31:0] data_reg;

//wire gpio_inta_o;

wire [31:0]extc_in; //mixed inputs sampled by external clock
reg [31:0] pextc_sampled; //posedge external clock sampled inputs
reg [31:0] nextc_sampled;//negedge external clock sampled inputs

//rgpio_ctrl logic

always@(posedge sysclk or posedge sysrst)
begin
if(sysrst)
rgpio_ctrl <= 32'b0;
else if((gpio_addr == `RGPIO_CTRL) && gpio_we)
rgpio_ctrl <= gpio_dat_i[1:0];
else if(rgpio_ctrl[`RGPIO_CTRL_INTE])
rgpio_ctrl[`RGPIO_CTRL_INTS] <= rgpio_ctrl[`RGPIO_CTRL_INTS] | gpio_inta_o;
else
rgpio_ctrl <= rgpio_ctrl;
end

//rgpio_out

always@(posedge sysclk or posedge sysrst)
begin
if(sysrst)
rgpio_out <= 32'b0;
else if((gpio_addr == `RGPIO_OUT) && gpio_we)
rgpio_out <= gpio_dat_i[31:0];
else
rgpio_out <= rgpio_out;
end

//rgpio_oe

always@(posedge sysclk or posedge sysrst)
begin
if(sysrst)
rgpio_oe <= 32'b0;
else if((gpio_addr == `RGPIO_OE) && gpio_we)
rgpio_oe <= gpio_dat_i[31:0];
else
rgpio_oe <= rgpio_oe;
end

//rgpio_inte

always@(posedge sysclk or posedge sysrst)
begin
if (sysrst)
rgpio_inte <= 32'b0;
else if((gpio_addr ==`RGPIO_INTE )&& gpio_we)
rgpio_inte <= gpio_dat_i[31:0];
else
rgpio_inte <= rgpio_inte;
end

//rgpio_ptrig

always@(posedge sysclk or posedge sysrst)
begin
if(sysrst)
rgpio_ptrig <= 32'b0;
else if((gpio_addr == `RGPIO_PTRIG )&& gpio_we)
rgpio_ptrig <= gpio_dat_i[31:0];
else
rgpio_ptrig <= rgpio_ptrig;
end

//rgpio_aux

always@(posedge sysclk or posedge sysrst)
begin
if(sysrst)
rgpio_aux <= 32'b0;
else if((gpio_addr == `RGPIO_AUX )&&gpio_we)
rgpio_aux <= gpio_dat_i[31:0];
else
rgpio_aux <= rgpio_aux;
end

//rgpio_eclk

always@(posedge sysclk or posedge sysrst)
begin
if (sysrst)
rgpio_eclk <= 32'b0;
else if((gpio_addr == `RGPIO_ECLK) && gpio_we)
rgpio_eclk <= gpio_dat_i[31:0];
else
rgpio_eclk <= rgpio_eclk;
end

//rgpio_nec

always@(posedge sysclk or posedge sysrst)
begin
if(sysrst)
rgpio_nec <= 32'b0;
else if((gpio_addr == `RGPIO_NEC) && gpio_we)
rgpio_nec <= gpio_dat_i[31:0];
else
rgpio_nec <= rgpio_nec;
end

//Latch into rgpio_in

wire [31:0] in_m;

always@(posedge sysclk or posedge sysrst)
begin
if (sysrst)
rgpio_in <= 32'b0;
else
rgpio_in <= in_m;
end
assign in_m=(rgpio_eclk & extc_in)|(~rgpio_eclk & in_pad_i);
assign extc_in=(~rgpio_nec & pextc_sampled) | (rgpio_nec & nextc_sampled);

//posedge external clock sampkled inputs

always@(posedge gpio_eclk or posedge sysrst)
begin
if (sysrst)
pextc_sampled <= 32'b0;
else
pextc_sampled <= in_pad_i;

end

always@(posedge gpio_eclk or posedge sysrst)
begin
if(sysrst)
nextc_sampled <= 32'b0;
else
nextc_sampled <= in_pad_i;

end

//Mux all registers when doing a read of GPIO registers

always@(*)
begin
case(gpio_addr)

`RGPIO_IN:begin
data_reg=rgpio_in;
end
`RGPIO_OUT:begin
data_reg=rgpio_out;
end
`RGPIO_OE:begin
data_reg=rgpio_oe;
end
`RGPIO_INTE:begin
data_reg=rgpio_inte;
end
`RGPIO_PTRIG:begin
data_reg=rgpio_ptrig;

end
`RGPIO_AUX:begin
data_reg=rgpio_aux;
end
`RGPIO_CTRL:begin
data_reg[1:0]=rgpio_ctrl;
data_reg[31:2]=30'b0;
end

`RGPIO_INTS:begin
data_reg=rgpio_ints;
end

`RGPIO_ECLK:begin
data_reg=rgpio_eclk;
end

`RGPIO_NEC:begin
data_reg=rgpio_nec;
end
default:begin
data_reg=rgpio_in;
end

endcase
end

//Data output

always@(posedge sysclk or posedge sysrst)
begin
if(sysrst)
gpio_dat_o <= 32'b0;
else
gpio_dat_o <= data_reg;
end

//RGPIO INTS write and read operation

always@(posedge sysclk or posedge sysrst)
begin
if(sysrst)
rgpio_ints <= 32'b0;
else if((gpio_addr == `RGPIO_INTS)&& gpio_we)
rgpio_ints <= gpio_dat_i;
else if(rgpio_ctrl[ `RGPIO_CTRL_INTE])
rgpio_ints <= (rgpio_ints|((in_m^rgpio_in)&~(in_m^rgpio_ptrig)&rgpio_inte));
else
rgpio_ints <= rgpio_ints;
end

//Generate interrupt request
assign gpio_inta_o=(|rgpio_ints)?(rgpio_ctrl[`RGPIO_CTRL_INTE]):1'b0;

//output enables are RGPIO_OE bits

assign oen_padoe_o=rgpio_oe;

//Generate GPIO outputs

assign out_pad_o=rgpio_out&~rgpio_aux|aux_i&rgpio_aux;

endmodule