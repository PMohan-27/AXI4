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

        .ctrl_addr      (ctrl_addr),
        .ctrl_wdata     (ctrl_wdata),
        .ctrl_wstrb     (4'hF),
        .ctrl_write_req (ctrl_write_req),
        .ctrl_read_req  (1'b0),

        .ctrl_rdata     (),
        .ctrl_write_done(),
        .ctrl_read_done (),
        .ctrl_resp      ()
    );

    axi4_lite_slave s1 (
        .axi (axi_if),

        .ctrl_addr      (),
        .ctrl_wdata     (),
        .ctrl_wstrb     (),
        .ctrl_write_req (),
        .ctrl_read_req  (),
        .ctrl_rdata     (),
        .ctrl_write_done(),
        .ctrl_read_done (),
        .ctrl_resp      ()
    );

endmodule
