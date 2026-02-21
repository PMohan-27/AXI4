module axi4_lite_top (
    input  logic        clk,
    input  logic        rst_n,

    input  logic        ctrl_write_req,
    input  logic [31:0] ctrl_addr,
    input  logic [31:0] ctrl_wdata
);

    axi_lite_if axi_if (
        .ACLK    (clk),
        .ARESETn (rst_n)
    );

    axi4_lite_master m1 (
        .axi            (axi_if),

        .ctrl_waddr      (ctrl_addr),
        .ctrl_raddr      (ctrl_addr),
        .ctrl_wdata     (ctrl_wdata),
        .ctrl_wstrb     (4'hF),
        .ctrl_write_req (ctrl_write_req),
        .ctrl_read_req  (1'b0),

        .ctrl_rdata     (),
        .ctrl_write_done(),
        .ctrl_read_done (), 
        .ctrl_bresp      (),
        .ctrl_rresp      ()
    );

    axi4_lite_slave s1 (
        .axi (axi_if),

        .slave_raddr(),
        .slave_waddr(),
        .slave_wdata(),
        .slave_wstrb(),
        .send_slave_write(),
        .send_slave_read(),

        .slave_rdata(),
        .slave_write_done(),
        .slave_read_done(),
        .slave_rresp(),
        .slave_bresp()
    );

endmodule
