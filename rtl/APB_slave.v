module APB_slave_interface(input pclk, presetn, psel, penable, pwrite, input [31:0]paddr, pwdata,gpio_dat_o, input gpio_inta_o, output pready, sysclk, sysrst, output reg
gpio_we, output [31:0]gpio_addr, output reg [31:0] gpio_dat_i, prdata, output irq);

parameter IDLE=2'b00,
	  ENABLE=2'b10,
	  SETUP=2'b01;
reg [1:0]ps,ns;

always@(posedge pclk)
begin
if (!presetn)
ps <= IDLE;
else
ps <= ns;
end

always@(*)
begin
ns=IDLE;
case(ps)
IDLE:if ((psel && !penable))
ns=SETUP;
else if (!psel && !penable)
ns=IDLE;
SETUP:if(psel && penable)
ns=ENABLE;
else if (psel && !penable)
ns=SETUP;
ENABLE: if(psel && penable)
ns=ENABLE;
else if(!psel && !penable)
ns=IDLE;
else if(psel && !penable)
ns=SETUP;
endcase
end
assign sysclk=pclk;
assign sysrst = ~presetn;
assign gpio_addr=paddr;
assign irq=gpio_inta_o;

always@(*)
begin
if (pwrite && ps == ENABLE)
begin
gpio_dat_i=pwdata;
gpio_we=1'b1;
end

else if (!pwrite && ps == ENABLE)
begin
prdata=gpio_dat_o;
gpio_we=1'b0;
end
else
begin
prdata=prdata;
gpio_dat_i=gpio_dat_i;
end

end

assign pready=(ps == ENABLE)?1'b1:1'b0;
endmodule
