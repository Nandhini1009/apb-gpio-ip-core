`timescale 1ns/1ps

module tb_APB_slave_interface;

  // Testbench signals
  reg pclk;
  reg presetn;
  reg psel;
  reg penable;
  reg pwrite;
  reg [31:0] paddr;
  reg [31:0] pwdata;
  reg [31:0] gpio_dat_o;      // Read data coming from GPIO register block
  reg gpio_inta_o;

  wire pready;
  wire sysclk;
  wire sysrst;
  wire gpio_we;
  wire [31:0] gpio_addr;
  wire [31:0] gpio_dat_i;
  wire [31:0] prdata;
  wire irq;

  // Instantiate the DUT (Design Under Test)
  APB_slave_interface dut (
    .pclk(pclk),
    .presetn(presetn),
    .psel(psel),
    .penable(penable),
    .pwrite(pwrite),
    .paddr(paddr),
    .pwdata(pwdata),
    .gpio_dat_o(gpio_dat_o),
    .gpio_inta_o(gpio_inta_o),
    .pready(pready),
    .sysclk(sysclk),
    .sysrst(sysrst),
    .gpio_we(gpio_we),
    .gpio_addr(gpio_addr),
    .gpio_dat_i(gpio_dat_i),
    .prdata(prdata),
    .irq(irq)
  );

  // Clock generation (10ns period)
  always #5 pclk = ~pclk;

  initial begin
    // Initialize signals
    pclk = 0;
    presetn = 0;
    psel = 0;
    penable = 0;
    pwrite = 0;
    paddr = 32'h0000_0000;
    pwdata = 32'h0000_0000;
    gpio_dat_o = 32'hAAAA_AAAA;
    gpio_inta_o = 0;

    // Apply reset
    #10;
    presetn = 1;

    // ---------------------
    // Write Transaction
    // ---------------------
    #10;
    paddr = 32'h0000_0010;        // Example address
    pwdata = 32'h1234_5678;       // Example data
    pwrite = 1;                   // Write operation
    psel = 1;                     // Select
    penable = 0;                  // Setup phase

    #10;
    penable = 1;                  // Enable phase

    #10;
    psel = 0;
    penable = 0;

    // ---------------------
    // Read Transaction
    // ---------------------
    #20;
    paddr = 32'h0000_0010;        // Address to read
    pwrite = 0;                   // Read operation
    psel = 1;
    penable = 0;                  // Setup phase

    #10;
    penable = 1;                  // Enable phase

    #10;
    psel = 0;
    penable = 0;

    // Finish simulation
    #50;
    $finish;
  end

  // Optional: Monitor signals
  initial begin
    $monitor("Time=%0t | psel=%b, penable=%b, pwrite=%b, paddr=%h, pwdata=%h, prdata=%h, gpio_we=%b, pready=%b", 
              $time, psel, penable, pwrite, paddr, pwdata, prdata, gpio_we, pready);
  end

endmodule

