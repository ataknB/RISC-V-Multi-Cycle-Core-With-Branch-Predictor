module processor_top_tb;

    logic clk = 1'b0;
    logic rst;
    integer i;
  // Instance of the processor_top module
  Processor_Top tb(
    .clk(clk),
    .rst(rst)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;  
  end

  // Reset signal
  initial begin
    rst = 0;
    #2;  
    
    rst = 1;
    #15000;   
    
    $finish;
  end

  // Dump PC, Instruction, and Register File
  initial begin
    forever @(posedge clk) begin
      $display("=== Processor State at time %0t ===", $time);
      // Register File Contents
      for ( i = 0; i < 32; i=i+1) begin
        $display("R[%0d] = %h", i, tb.RF_.reg_data[i]);
      end

      $display("==============================");
    end
  end

endmodule
