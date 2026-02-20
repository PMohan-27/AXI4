module axi4_lite_slave #(parameter DATA_WIDTH = 32, ADDRESS_WIDTH = 32)(
    output logic [ADDRESS_WIDTH-1:0] slave_addr,
    output logic [DATA_WIDTH-1:0] slave_wdata,
    output logic [(DATA_WIDTH/8)-1 : 0] slave_wstrb,
    output logic send_slave_write,
    output logic send_slave_read,
    input logic [DATA_WIDTH-1:0] slave_rdata,
    input logic slave_write_done,
    input logic slave_read_done,
    input logic [1:0] slave_resp,

    axi_lite_if.slave axi
);

    // NOTE: In SoC integration, ARESETn is assumed synchronized externally.
    logic rst_sync1, rst_sync2;
    always_ff @(posedge axi.ACLK or negedge axi.ARESETn) begin
        if(!axi.ARESETn)begin
            rst_sync1 <= 1'b0;
            rst_sync2 <= 1'b0;
        end
        else begin 
            rst_sync1 <= 1'b1;
            rst_sync2 <= rst_sync1;
        end
    end

endmodule
