module GPIO_top(input pclk, presetn, psel, penable, pwrite, input [31:0] paddr, pwdata, aux_in, output irq, pready, inout [31:0]io_pad, input ext_clk_pad_i, output [31:0]prdata);

wire sysclk,sysrst,gpio_we;

wire [31:0]gpio_addr,gpio_dat_i,gpio_dat_o,aux_i, out_pad_o,oen_padoe_o, in_pad_i;
wire gpio_eclk;
APB_slave_interface apb( pclk,presetn,psel,penable,pwrite,paddr,pwdata,gpio_dat_o, gpio_inta_o, pready, sysclk, sysrst, gpio_we,gpio_addr,gpio_dat_i,prdata, irq);

aux_interface aux( sysclk ,sysrst, aux_in, aux_i);

GPIO_register gp(sysclk,sysrst,gpio_we,gpio_addr,gpio_dat_i,aux_i, in_pad_i, gpio_eclk,gpio_inta_o,gpio_dat_o, out_pad_o,oen_padoe_o);
io_interface io ( out_pad_o,oen_padoe_o, io_pad, in_pad_i);
endmodule