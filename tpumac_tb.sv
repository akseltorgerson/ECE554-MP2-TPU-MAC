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

  logic signed [7:0] Ain_old, Aout_old;
  logic signed [7:0] Bin_old, Bout_old;
  logic signed [15:0] Cin_old, Cout_old;

  logic signed [15:0] expected;

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
    Cin = 16'b0000000000001000;
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

    WrEn = 0;
    en = 0;
    Ain_old = Ain;
    Bin_old = Bin;
    Cout_old = Cout;
    Ain = 8'b00000100; // 4
    Bin = 8'b00000010; // 2
    Cin = 16'b0000000000000001; // 1

    #20;

    if (Aout != Ain_old || Bout != Bin_old) begin
      errors++;
      $display("Aout or Bout not same values as Ain or Bin!");
    end
    if (Cout != Cout_old) begin
      errors++;
      $display("Cout should not change on low enable!");
      $display("Cout: " + Cout);
    end

    en = 1;
    rst_n = 0;
    WrEn = 0;
    @(negedge clk);
    @(posedge clk);
    #1;

    
    // Testing first stage of multiplication, no accumulation, no Cin    
    for (int i = 0; i < 9; i++) begin
      WrEn = 0;
      en = 1;
      rst_n = 1;
      Ain = $random();
      Bin = $random();
      Cin = $random();

      expected = (Ain * Bin) + Cout;
  
      @(negedge clk);
      @(posedge clk);
      #1;

      if (Cout != expected) begin
        errors++;
        $display("Oopsie whoopsie");
        $display("Ain: " + Ain);
        $display("Bin: " + Bin);
        $display("Cout: " + Cout);
      end

      rst_n = 0;
      @(negedge clk);
      @(posedge clk);
      #1;
    end

    // Testing muliplication and accumulation, with Cin, Ain and Bin don't change.
    for (int i = 0; i < 32; i++) begin
      WrEn = 1;
      en = 1;
      rst_n = 1;
      Ain = $random();
      Bin = $random();
      Cin = $random();

      @(negedge clk);
      @(posedge clk);
      #1;

      expected = (Ain * Bin) + Cin;

      if (Cout != Cin) begin
        errors++;
        $display("Cout expected: " + Cin + "     Cout found: " + Cout);
      end

      WrEn = 0;
      // random amount of accumulation, Ain and Bin not changing.
      for (int j = 0; j < 4; j++) begin
        expected = (Ain * Bin) + Cout;
        @(negedge clk);
        @(posedge clk);
        #1;

        if (Cout != expected) begin
          errors++;
          $display("Cout expected: " + expected + "     Cout found: " + Cout);
        end
          
      end

      rst_n = 0;
      @(negedge clk);
      @(posedge clk);
      #1;


    end





    if (errors == 0) begin
      $display("YAHOO! All tests passed");
    end else begin
      $display("YOU FUCKED UP!");
    end

    $stop();

  end

endmodule
