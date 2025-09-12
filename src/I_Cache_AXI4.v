`include "SYSTEM_DEF.vh"

module I_Cache_AXI4 (
    // ===== AXI clock/reset =====
    input aclk,
    input aresetn,

    // ===== M_AXI (AXI4 Read-only Master) =====
    output [`INSTR_ADDR_WIDTH-1:0] M_AXI_ARADDR,
    output [7:0] M_AXI_ARLEN,   // AXI4 8-bit
    output [2:0] M_AXI_ARSIZE,
    output [1:0] M_AXI_ARBURST,
    output M_AXI_ARLOCK,  // AXI4: 1-bit
    output [3:0] M_AXI_ARCACHE,
    output [2:0] M_AXI_ARPROT,
    output [3:0] M_AXI_ARQOS,
    output M_AXI_ARVALID,
    input M_AXI_ARREADY,

    input [`DATA_WIDTH-1:0] M_AXI_RDATA,
    input [1:0] M_AXI_RRESP,
    input M_AXI_RLAST,
    input M_AXI_RVALID,
    output M_AXI_RREADY,

    // ===== 你 I-Cache 的 CPU 端 =====
    input cpu_req,
    input [`INSTR_ADDR_WIDTH-1:0] cpu_req_addr,
    output cpu_req_ready,
    output [`DATA_WIDTH-1:0]  cpu_req_data,
    input flush,
    output busy
);

  // ---- 常見 tie-offs（可依 SoC 政策調整）----
  assign M_AXI_ARLOCK  = 1'b0;       // AXI4 1-bit
  assign M_AXI_ARCACHE = 4'b0000;    // cacheable, modifiable（或依要求）
  assign M_AXI_ARPROT  = 3'b000;     // instruction, unprivileged, secure（僅示意）
  assign M_AXI_ARQOS   = 4'b0000;

  // ---- 連到你的 I_Cache ----
  wire arvalid, rready;
  wire [`INSTR_ADDR_WIDTH-1:0] araddr;
  wire [7:0] arlen;     // ★ 你已改成 8-bit
  wire [2:0] arsize;
  wire [1:0] arburst;

  // AXI → I_Cache 回傳
  wire arready = M_AXI_ARREADY;
  wire rvalid = M_AXI_RVALID;
  wire rlast = M_AXI_RLAST;
  wire [`DATA_WIDTH-1:0] rdata = M_AXI_RDATA;

  // 對外映射
  assign M_AXI_ARADDR = araddr;
  assign M_AXI_ARLEN = arlen;
  assign M_AXI_ARSIZE = arsize;
  assign M_AXI_ARBURST = arburst;
  assign M_AXI_ARVALID = arvalid;
  assign M_AXI_RREADY = rready;

  // === 實例化你的 I_Cache ===
  I_Cache u_icache (
    .clk          (aclk),
    .rst_n        (aresetn),

    .cpu_req      (cpu_req),
    .cpu_req_addr (cpu_req_addr),
    .cpu_req_ready(cpu_req_ready),
    .cpu_req_data (cpu_req_data),

    .flush        (flush),
    .busy         (busy),

    .arvalid      (arvalid),
    .rready       (rready),
    .araddr       (araddr),
    .arlen        (arlen),     // ★ 8-bit
    .arsize       (arsize),
    .arburst      (arburst),

    .arready      (arready),
    .rvalid       (rvalid),
    .rlast        (rlast),
    .rdata        (rdata)
  );

  // 可選：處理 RRESP（例如遇到 SLVERR/DECERR 丟棄 refill）
  // wire resp_ok = (M_AXI_RRESP == 2'b00);

endmodule
