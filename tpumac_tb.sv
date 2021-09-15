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

  // Signed register to keep track of expected values.
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
    clk = 0;
    // ------------- Test 1: en and WrEn low ----------------------------------
    $display("Starting Test 1...");
    Ain = $random();
    Bin = $random();
    en = 0;
    WrEn = 0;
    rst_n = 0;
    
    @(negedge clk);
    @(posedge clk);
    #1;
    rst_n = 1;

    if (Aout != 2'h0 || Bout != 2'h0 || Cout != 2'h0) begin
      errors++;
      $display("Error: Aout, Bout, or Cout are not reset properly.");
    end

    // Wait another clock cycle, enable is low so values should be held to 0.
    @(negedge clk);
    @(posedge clk);
    #1;

    if (Aout != 2'h0 || Bout != 2'h0 || Cout != 2'h0) begin
      errors++;
      $display("Error: Aout, Bout, or Cout are not held to reset value.");
    end



    // ------------- Test 2: en low WrEn high ---------------------------------
    $display("Starting Test 2...");
    Ain = $random();
    Bin = $random();
    Cin = $random();
    en = 0;
    WrEn = 1;
    rst_n = 0;

    @(negedge clk);
    @(posedge clk);
    #1;
    rst_n = 1;

    // Cout should still hold reset value, despite WrEn high
    if (Aout != 2'h0 || Bout != 2'h0 || Cout != 2'h0) begin
      errors++;
      $display("Error: Ain, Bin, or Cout are not reset properly.");
    end

    // Wait another clock cycle, enable is low so values should be held to 0.
    @(negedge clk);
    @(posedge clk);
    #1;

    if (Aout != 2'h0 || Bout != 2'h0 || Cout != 2'h0) begin
      errors++;
      $display("Error: Ain, Bin, or Cout are not held to reset value.");
    end


    // ------------- Test 3: en high WrEn low ---------------------------------
    $display("Starting Test 3...");
    Ain = $random();
    Bin = $random();
    Cin = $random();
    en = 1;
    WrEn = 0;
    rst_n = 0;

    @(negedge clk);
    @(posedge clk);
    #1;
    rst_n = 1;
    expected = (Ain * Bin) + Cout;
    @(negedge clk);
    @(posedge clk);
    #1

    if (Aout != Ain || Bout != Bin || Cout != expected) begin
      errors++;
      $display("Error: Ain, Bin, or Cout are not calculated correctly.");
    end

    // Change of Cin should not affect output, WrEn is low.
    Cin = $random();
    expected = (Ain * Bin) + Cout;
    @(negedge clk);
    @(posedge clk);
    #1;

    if (Aout != Ain || Bout != Bin || Cout != expected) begin
      errors++;
      $display("Error: Ain, Bin, or Cout are not calculated correctly.");
    end


    // ------------- Test 4: en high WrEn high --------------------------------
    $display("Starting Test 4...");
    Ain = $random();
    Bin = $random();
    Cin = $random();
    en = 1;
    WrEn = 1;
    rst_n = 0;

    @(negedge clk);
    @(posedge clk);
    #1;
    rst_n = 1;
    @(negedge clk);
    @(posedge clk);
    #1;

    if (Cout != Cin) begin
      errors++;
      $display("Error: Cout does not equal Cin when WrEn is high.");
    end

    // Change of Cin should affect output, WrEn is high.
    Cin = $random();
    @(negedge clk);
    @(posedge clk);
    #1

    if (Cout != Cin) begin
      errors++;
      $display("Error: Cout does not equal Cin when WrEn is high.");
    end


    // -------------- Test 5: Multiple multiplication, no accumulation --------
    $display("Starting Test 5...");
    rst_n = 0;
    @(negedge clk);
    @(posedge clk);
    #1;
    
    for (int i = 0; i < 32; i++) begin
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
        $display("Cout expected: " + expected + "     Cout found: " + Cout);
      end

      rst_n = 0;
      @(negedge clk);
      @(posedge clk);
      #1;
    end

    // ------------- Test 6: Multiplication and accumulation ------------------
    $display("Starting Test 6...");
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
      
      // Accumulate a random amount of times.
      for (int j = 0; j < $urandom_range(1,32); j++) begin
        
        // Randomly change Ain and Bin
        if ($urandom_range(1,10) < 5) begin
          Ain = $random();
          Bin = $random();
        end
        
        expected = (Ain * Bin) + Cout;
        @(negedge clk);
        @(posedge clk);
        #1;

        if (Aout != Ain || Bout != Bin) begin
          errors++;
          $display("Aout and Bout did not update after changed");
        end

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
