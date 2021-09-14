module tpumac_tb();

  // Signals
  logic clk;
  logic rst_n;
  logic en;
  logic WrEn;

  logic signed [7:0] Ain;
  logic signed [7:0] Bin;
  logic signed [15:0] Cin;

  logic signed [7:0] Aout;
  logic signed [7:0] Bout;
  logic signed [15:0] Cout;

  // Need clk to always alternate.
  always #5 clk = ~clk;

  // Keep track of simulation errors.
  int errors = 0;

  // Instantiate the DUT.
  tpumac iDUT(.clk(clk),
              .rst_n(rst_n),
              .en(en),
              .WrEn(WrEn),
              .Ain(Ain),
              .Bin(Bin),
              .Cin(Cin),
              .Aout(Aout),
              .Bout(Bout),
              .Cout(Cout));


  initial begin
    Ain = 8'b01010101;
    Bin = 8'b11111111;
    Cin = 16'b0000000011110000;
    clk = 0;
    rst_n = 0;
    en = 0;
    WrEn = 0;
    
    #20;
    if (Aout != 8'b0 || Bout != 8'b0 || Cout != 16'b0) begin
      errors++;
      $display("Reset values not correct!");
    end
    rst_n = 1;
    en = 1;
    WrEn = 1;
    
    #20;
    if (Aout != Ain || Bout != Bin) begin
      errors++;
      $display("Aout or Bout not same values as Ain or Bin!");
    end
    if (Cout != Cin) begin
      errors++;
      $display("Cout does not equal Cin on active WrEn!");
    end





    if (errors == 0) begin
      $display("YAHOO! All tests passed");
    end else begin
      $display("YOU FUCKED UP!");
    end

  end

endmodule
