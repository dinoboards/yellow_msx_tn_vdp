/*
The memory_controller module is designed to interface with the GOWIN's SDRAM memory module. It provides
upto 8MBytes of storage, organized as 4M 16-bit words. The module supports read, write, and auto-
refresh operations, controlled by the read, write, and refresh inputs respectively.

For write operations, the wdm (write data mask) input is used to specify which byte (or bytes) of the
16-bit data word is to be updated. For read operations, both bytes of the 16-bit word are retrieved.

* If wdm is 01, then only the lower 8 bits are written;
* if wdm is 10, then only the upper 8 bits are written;
* if wdm is 11, then both bytes are written;
* if wdm is 00, then nothing will be updated.

The module provides a busy output to indicate when an operation is in progress, and a fail output
to indicate a timing mistake or SDRAM malfunction.

The physical interface to the SDRAM is provided by the IO_sdram_dq, O_sdram_addr, O_sdram_ba, O_sdram_cs_n,
O_sdram_wen_n, O_sdram_ras_n, O_sdram_cas_n, O_sdram_clk, O_sdram_cke, and O_sdram_dqm signals.  These must
map to the gowin special pins to access the onchip SDRAM
*/

module memory_controller #(
    parameter int FREQ = 54_000_000
) (
    input             clk,        // Main logic clock (max speed is 166.7Mh - see SRAM.v)
    input             clk_sdram,  // A clock signal that is 180 degrees out of phase with the main clock.
    input             resetn,     // Active low reset signal.
    input             read,       // Signal to initiate a read operation from the SDRAM
    input             write,      // Signal to initiate a write operation to the SDRAM
    input             refresh,    // Signal to initiate an auto-refresh operation in the SDRAM
    input      [21:0] addr,       // The address to read from or write to in the SDRAM
    input      [15:0] din,        // The data to be written to the SDRAM (only the byte specified by wdm is written)
    input      [ 1:0] wdm,        // Write data mask
    output     [15:0] dout,       // The data read from the SDRAM. Available 4 cycles after the read signal is set.
    output reg        busy,       // Signal indicating that an operation is in progress.
    output            enabled,    // Signal indicating that the memory controller is enabled.

    // debug interface
    output reg fail,  // Signal indicating a timing mistake or SDRAM malfunction

    // GoWin's Physical SDRAM interface
    inout  [31:0] IO_sdram_dq,    // 32 bit bidirectional data bus
    output [10:0] O_sdram_addr,   // 11 bit multiplexed address bus
    output [ 1:0] O_sdram_ba,     // 4 banks
    output        O_sdram_cs_n,   // chip select
    output        O_sdram_wen_n,  // write enable
    output        O_sdram_ras_n,  // row address strobe
    output        O_sdram_cas_n,  // columns address strobe
    output        O_sdram_clk,    // sdram's clock
    output        O_sdram_cke,    // sdram's clock enable
    output [ 3:0] O_sdram_dqm     // data mask control
);

  reg [22:0] MemAddr;
  reg MemRD, MemWR, MemRefresh, MemInitializing;
  reg [15:0] MemDin;
  wire [15:0] MemDout;
  reg [2:0] cycles;
  reg r_read;
  reg [15:0] data;
  wire MemBusy, MemDataReady;

  assign dout = (cycles == 3'd4 && r_read) ? MemDout : data;

  // SDRAM driver
  sdram #(
      .FREQ(FREQ)
  ) u_sdram (
      .clk(clk),
      .clk_sdram(clk_sdram),
      .resetn(resetn),
      .addr(busy ? MemAddr : {1'b0, addr}),
      .rd(busy ? MemRD : read),
      .wr(busy ? MemWR : write),
      .refresh(busy ? MemRefresh : refresh),
      .din(busy ? MemDin : din),
      .wdm(wdm),
      .dout(MemDout),
      .busy(MemBusy),
      .data_ready(MemDataReady),
      .enabled(enabled),

      .IO_sdram_dq(IO_sdram_dq),
      .O_sdram_addr(O_sdram_addr),
      .O_sdram_ba(O_sdram_ba),
      .O_sdram_cs_n(O_sdram_cs_n),
      .O_sdram_wen_n(O_sdram_wen_n),
      .O_sdram_ras_n(O_sdram_ras_n),
      .O_sdram_cas_n(O_sdram_cas_n),
      .O_sdram_clk(O_sdram_clk),
      .O_sdram_cke(O_sdram_cke),
      .O_sdram_dqm(O_sdram_dqm),

      .dout32()
  );

  always @(posedge clk or negedge resetn) begin

    if (~resetn) begin
      busy <= 1'b1;
      fail <= 1'b0;
      MemInitializing <= 1'b1;
    end else begin
      MemWR <= 1'b0;
      MemRD <= 1'b0;
      MemRefresh <= 1'b0;
      cycles <= cycles == 3'd7 ? 3'd7 : cycles + 3'd1;

      // Initiate read or write
      if (!busy) begin
        if (read || write || refresh) begin
          MemAddr <= {1'b0, addr};
          MemWR <= write;
          MemRD <= read;
          MemRefresh <= refresh;
          busy <= 1'b1;
          MemDin <= din;
          cycles <= 3'd1;
          r_read <= read;

        end
      end else if (MemInitializing) begin
        if (~MemBusy) begin
          // initialization is done
          MemInitializing <= 1'b0;
          busy <= 1'b0;
        end
      end else begin
        // Wait for operation to finish and latch incoming data on read.
        if (cycles == 3'd4) begin
          busy <= 0;
          if (r_read) begin
            if (~MemDataReady)  // assert data ready
              fail <= 1'b1;
            if (r_read) data <= MemDout;
            r_read <= 1'b0;
          end
        end
      end
    end
  end

endmodule
