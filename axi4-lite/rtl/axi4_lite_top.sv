module axi4_lite_top (
    input  logic clk,
    input  logic rst_n,

    input  logic        ctrl_write_req,
    input  logic        ctrl_read_req,
    input  logic [31:0] ctrl_waddr,
    input  logic [31:0] ctrl_raddr,
    input  logic [31:0] ctrl_wdata,
    input  logic [3:0]  ctrl_wstrb,

    output logic [31:0] ctrl_rdata,
    output logic        ctrl_write_done,
    output logic        ctrl_read_done,
    output logic [1:0]  ctrl_bresp,
    output logic [1:0]  ctrl_rresp,

    output logic [31:0] slave_raddr,
    output logic [31:0] slave_waddr,
    output logic [31:0] slave_wdata,
    output logic [3:0]  slave_wstrb,

    output logic        send_slave_write,
    output logic        send_slave_read,

    input  logic [31:0] slave_rdata,
    input  logic        slave_write_done,
    input  logic        slave_read_done,
    input  logic [1:0]  slave_rresp,
    input  logic [1:0]  slave_bresp
);

    axi_lite_if axi_if (
        .ACLK    (clk),
        .ARESETn (rst_n)
    );

    axi4_lite_master m1 (
        .axi (axi_if),

        .ctrl_waddr      (ctrl_waddr),
        .ctrl_raddr      (ctrl_raddr),
        .ctrl_wdata      (ctrl_wdata),
        .ctrl_wstrb      (ctrl_wstrb),
        .ctrl_write_req  (ctrl_write_req),
        .ctrl_read_req   (ctrl_read_req),

        .ctrl_rdata      (ctrl_rdata),
        .ctrl_write_done (ctrl_write_done),
        .ctrl_read_done  (ctrl_read_done),
        .ctrl_bresp      (ctrl_bresp),
        .ctrl_rresp      (ctrl_rresp)
    );

    axi4_lite_slave s1 (
        .axi (axi_if),

        .slave_raddr      (slave_raddr),
        .slave_waddr      (slave_waddr),
        .slave_wdata      (slave_wdata),
        .slave_wstrb      (slave_wstrb),

        .send_slave_write (send_slave_write),
        .send_slave_read  (send_slave_read),

        .slave_rdata      (slave_rdata),
        .slave_write_done (slave_write_done),
        .slave_read_done  (slave_read_done),
        .slave_rresp      (slave_rresp),
        .slave_bresp      (slave_bresp)
    );

endmodule