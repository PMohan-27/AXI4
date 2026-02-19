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

    // Write Addr/Data
    reg aw_recieved, w_recieved;
    always_ff @(posedge axi.ACLK) begin
        if(!rst_sync2) begin
            axi.AWREADY <= '0;
            axi.WREADY <= '0;
            send_slave_write <= '0;
            slave_addr <= '0;
            slave_wdata <= '0;
            slave_wstrb <= '0;
            aw_recieved <= '0;
            w_recieved <= '0;

        end
        else begin
            axi.AWREADY <= !send_slave_write && !axi.BVALID;
            axi.WREADY <= !send_slave_write && !axi.BVALID;
            if(axi.AWREADY && axi.AWVALID) begin
                slave_addr <= axi.AWADDR;
                aw_recieved <= 1'b1;
            end
            if(axi.WREADY && axi.WVALID) begin
                slave_wstrb <= axi.WSTRB;
                slave_wdata <= axi.WDATA;
                w_recieved <= 1'b1;
            end

            if(w_recieved && aw_recieved) begin
                send_slave_write <= 1'b1;
            end
            
        end
    end

    always_ff @(posedge axi.ACLK) begin
        if(!rst_sync2) begin
            axi.BRESP <= '0;
            axi.BVALID <= '0;
        end
        else begin
            if(slave_write_done) begin 
                axi.BRESP <= slave_resp;
                axi.BVALID <= 1'b1;
            end
            if(axi.BVALID && axi.BREADY) begin 
                axi.BVALID <= 1'b0;
            end

            if(send_slave_write && slave_write_done) begin
                send_slave_write <= 1'b0;
                w_recieved <= 1'b0;
                aw_recieved <= 1'b0;
            end
        end
    end

    // Read Address
    always_ff @(posedge axi.ACLK) begin
        if(!rst_sync2) begin
            axi.ARREADY <= '0;
            send_slave_read <= '0;
        end 
        else begin 
            axi.ARREADY <= !send_slave_read && !axi.RVALID;
            if(axi.ARREADY && axi.ARVALID) begin 
                send_slave_read <= 1'b1;
                slave_addr <= axi.ARADDR;
            end

        end
    end

    always_ff @(posedge axi.ACLK) begin 
        if(!rst_sync2) begin
            axi.RVALID <= '0;
            axi.RDATA <= '0;
            axi.RRESP <= '0;
        end
        else begin
            if(slave_read_done && !axi.RVALID) begin
                axi.RDATA <= slave_rdata;
                axi.RRESP <= slave_resp;
                axi.RVALID <= 1'b1;
            end

            if(axi.RREADY && axi.RVALID) begin
                axi.RVALID <= 1'b0;
                send_slave_read <= 1'b0;
            end
        end
    end
endmodule
