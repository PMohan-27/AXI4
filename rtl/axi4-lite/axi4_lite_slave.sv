module axi4_lite_slave #(parameter DATA_WIDTH = 32, ADDRESS_WIDTH = 32)(
    output logic [ADDRESS_WIDTH-1:0] ctrl_addr,
    output logic [DATA_WIDTH-1:0] ctrl_wdata,
    output logic [(DATA_WIDTH/8)-1 : 0] ctrl_wstrb,
    output logic ctrl_write_req,
    output logic ctrl_read_req,
    input logic [DATA_WIDTH-1:0] ctrl_rdata,
    input logic ctrl_write_done,
    input logic ctrl_read_done,
    input logic [1:0] ctrl_resp,

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

    // Write Addr/Data
    reg aw_recieved, w_recieved;
    always_ff @(posedge axi.ACLK) begin
        if(!rst_sync2) begin
            axi.AWREADY <= '0;
            axi.WREADY <= '0;
            ctrl_write_req <= '0;
            ctrl_addr <= '0;
            ctrl_wdata <= '0;
            ctrl_wstrb <= '0;
            aw_recieved <= '0;
            w_recieved <= '0;

        end
        else begin
            axi.AWREADY <= !ctrl_write_req && !axi.BVALID;
            axi.WREADY <= !ctrl_write_req && !axi.BVALID;
            if(axi.AWREADY && axi.AWVALID) begin
                ctrl_addr <= axi.AWADDR;
                aw_recieved <= 1'b1;
            end
            if(axi.WREADY && axi.WVALID) begin
                ctrl_wstrb <= axi.WSTRB;
                ctrl_wdata <= axi.WDATA;
                w_recieved <= 1'b1;
            end

            if(w_recieved && aw_recieved) begin
                ctrl_write_req <= 1'b1;
            end
            
        end
    end

    always_ff @(posedge axi.ACLK) begin
        if(!rst_sync2) begin
            axi.BRESP <= '0;
            axi.BVALID <= '0;
        end
        else begin
            if(ctrl_write_done) begin 
                axi.BRESP <= ctrl_resp;
                axi.BVALID <= 1'b1;
            end
            if(axi.BVALID && axi.BREADY) begin 
                axi.BVALID <= 1'b0;
            end

            if(ctrl_write_req && ctrl_write_done) begin
                ctrl_write_req <= 1'b0;
                w_recieved <= 1'b0;
                aw_recieved <= 1'b0;
            end
        end
    end
endmodule
