module axi4_lite_master #(parameter  int DATA_WIDTH = 32, parameter int ADDRESS_WIDTH = 32)(

    // Control Signals
    input logic [ADDRESS_WIDTH-1:0] ctrl_addr,
    input logic [DATA_WIDTH-1:0] ctrl_wdata,
    input logic [(DATA_WIDTH/8)-1 : 0] ctrl_wstrb,
    input logic ctrl_write_req,
    input logic ctrl_read_req,
    output logic [DATA_WIDTH-1:0] ctrl_rdata,
    output logic ctrl_write_done,
    output logic ctrl_read_done,
    output logic [1:0] ctrl_resp,

    axi_lite_if.master  axi
    
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

    //Write Address
    logic write_addr_state;
    always_ff @(posedge axi.ACLK) begin
        if(!rst_sync2) begin
            axi.AWADDR <= '0;
            axi.AWVALID <= '0;
            write_addr_state <= '0;
            axi.AWPROT <= 3'b001;
        end 
        else begin
            if(ctrl_write_req && !write_addr_state)begin
                write_addr_state <= 1'b1;
            end
            if(write_addr_state) begin
                axi.AWADDR <= ctrl_addr;
                axi.AWVALID <= 1'b1;
            end
            if(axi.AWVALID & axi.AWREADY) begin
                axi.AWVALID <= 1'b0;
                write_addr_state <= 1'b0;              
            end
        end
    end

    // Write Data
    logic write_data_state;
    always_ff @(posedge axi.ACLK) begin
        if(!rst_sync2) begin
            axi.WVALID <= '0;
            axi.WDATA <= '0;
            axi.WSTRB <= '1;
            write_data_state <= '0;
        end 
        else begin
            if(ctrl_write_req && !write_data_state) begin 
                write_data_state <= 1'b1;
            end
            if(write_data_state) begin
                axi.WDATA <= ctrl_wdata;
                axi.WSTRB <= ctrl_wstrb;
                axi.WVALID <= 1'b1;
            end
            if(axi.WVALID && axi.WREADY) begin
                axi.WVALID <= 1'b0;
                write_data_state <= 1'b0;
            end
        end
    end

    // Write Response
    logic w_finish, aw_finish;
    always_ff @(posedge axi.ACLK)begin
        if(!rst_sync2) begin
            axi.BREADY <= '0;
            w_finish <= '0;
            aw_finish <= '0;
            ctrl_write_done <= '0;
            ctrl_resp <= '0;
        end
        else begin
            if(axi.WREADY && axi.WVALID) begin
                w_finish <= 1'b1;
            end
            if(axi.AWREADY && axi.AWVALID) begin
                aw_finish <= 1'b1;
            end
            if(aw_finish && w_finish) begin
                axi.BREADY <= 1'b1;
            end
            if(axi.BREADY && axi.BVALID) begin
                ctrl_resp <= axi.BRESP;
                ctrl_write_done <= 1'b1;
                axi.BREADY <= 1'b0;
                w_finish <= 1'b0;
                aw_finish <= 1'b0;
            end 
            else begin ctrl_write_done <= 1'b0; end
        end
    end

    // Read Address
    logic read_addr_state;
    logic addr_sent;
    always_ff @(posedge axi.ACLK) begin
        if(!rst_sync2) begin
            axi.ARADDR <= '0;
            axi.ARVALID <= '0;
            read_addr_state <= '0;
            axi.ARPROT <= 3'b001;
            addr_sent <= '0;
        end 
        else begin
            if(ctrl_read_req && !read_addr_state)begin
                read_addr_state <= 1'b1;
            end
            if(read_addr_state) begin
                axi.ARADDR <= ctrl_addr;
                axi.ARVALID <= 1'b1;
            end
            if(axi.ARVALID && axi.ARREADY) begin
                axi.ARVALID <= 1'b0;
                read_addr_state <= 1'b0;     
                addr_sent <= 1'b1;         
            end
        end
    end

    // Read Data
    always_ff @(posedge axi.ACLK) begin
        if(!rst_sync2) begin
            axi.RREADY <= '0;
            ctrl_read_done <= '0;
        end
        else begin
            if(addr_sent)begin
                axi.RREADY <= 1'b1;
            end
            if(axi.RREADY && axi.RVALID && addr_sent) begin
                ctrl_rdata <= axi.RDATA;
                ctrl_resp  <= axi.RRESP;
                axi.RREADY <= 1'b0;
                ctrl_read_done <= 1'b1;
                addr_sent <= 1'b0;
            end else begin 
                ctrl_read_done <= 1'b0;
            end
        end
    end
endmodule