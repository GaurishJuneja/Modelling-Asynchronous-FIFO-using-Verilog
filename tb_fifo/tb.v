`timescale 1ns/1ps

module async_fifo1_tb;

  parameter DSIZE = 8;
  parameter ASIZE = 4;

  wire [DSIZE-1:0] rdata;
  wire wfull;
  wire rempty;
  reg [DSIZE-1:0] wdata;
  reg winc, wclk, wrst_n;
  reg rinc, rclk, rrst_n;

  // Model a queue for checking data using standard Verilog arrays and pointers
  reg [DSIZE-1:0] verif_data_q [0:255];
  integer queue_wr_ptr;
  integer queue_rd_ptr;
  reg [DSIZE-1:0] verif_wdata;

  // Instantiate the FIFO with explicit port mapping
  async_fifo1 #(DSIZE, ASIZE) dut (
    .rdata(rdata),
    .wfull(wfull),
    .rempty(rempty),
    .wdata(wdata),
    .winc(winc),
    .wclk(wclk),
    .wrst_n(wrst_n),
    .rinc(rinc),
    .rclk(rclk),
    .rrst_n(rrst_n)
  );

  // GTKWave VCD Dump Configuration
  initial begin
    $dumpfile("async_fifo1_tb.vcd");
    $dumpvars(0, async_fifo1_tb);
  end

  // Initialize queue pointers
  initial begin
    queue_wr_ptr = 0;
    queue_rd_ptr = 0;
  end

  initial begin
    wclk = 1'b0;
    rclk = 1'b0;

    fork
      forever #10 wclk = ~wclk;
      forever #35 rclk = ~rclk;
    join
  end

  // Named block to allow standard Verilog local variable declarations
  initial begin : write_block
    integer iter;
    integer i;

    winc = 1'b0;
    wdata = 0;
    wrst_n = 1'b0;
    repeat(5) @(posedge wclk);
    wrst_n = 1'b1;

    for (iter=0; iter<2; iter = iter + 1) begin
      for (i=0; i<32; i = i + 1) begin
        begin : wait_wfull
          forever begin
            @(posedge wclk);
            if (!wfull) disable wait_wfull;
          end
        end
        
        winc = (i%2 == 0)? 1'b1 : 1'b0;
        if (winc) begin
          wdata = $random;
          verif_data_q[queue_wr_ptr] = wdata;
          queue_wr_ptr = queue_wr_ptr + 1;
        end
      end
      #1000; // 1us delay
    end
  end

  // Named block to allow standard Verilog local variable declarations
  initial begin : read_block
    integer iter;
    integer i;

    rinc = 1'b0;
    rrst_n = 1'b0;
    repeat(8) @(posedge rclk);
    rrst_n = 1'b1;

    for (iter=0; iter<2; iter = iter + 1) begin
      for (i=0; i<32; i = i + 1) begin
        begin : wait_rempty
          forever begin
            @(posedge rclk);
            if (!rempty) disable wait_rempty;
          end
        end
        
        rinc = (i%2 == 0)? 1'b1 : 1'b0;
        if (rinc) begin
          verif_wdata = verif_data_q[queue_rd_ptr];
          queue_rd_ptr = queue_rd_ptr + 1;
          
          // Check the rdata against modeled wdata
          $display("Checking rdata: expected wdata = %h, rdata = %h", verif_wdata, rdata);
          if (!(rdata === verif_wdata)) begin
            $display("ERROR: Checking failed: expected wdata = %h, rdata = %h", verif_wdata, rdata);
          end
        end
      end
      #1000; // 1us delay
    end

    $finish;
  end

endmodule