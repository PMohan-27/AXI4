module axi4_lite_top (
    input logic clk,
    input logic rst_n
);
    axi_lite_if axi_if(.ACLK(clk), .ARESETn(rst_n));

    axi4_lite_master dut (
        .axi            (axi_if),

        .ctrl_addr      ('0),
        .ctrl_wdata     ('0),
        .ctrl_wstrb     ('0),
        .ctrl_write_req (1'b0),
        .ctrl_read_req  (1'b0),

        .ctrl_rdata     (),
        .ctrl_write_done(),
        .ctrl_read_done (),
        .ctrl_resp      ()
    );

endmodule