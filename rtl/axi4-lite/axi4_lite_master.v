module axi4_lite #(parameter DATA_WIDTH = 32, ADDRESS_WIDTH = 32)(
    // Global
    input ACLK,
    input ARESETn,

    // Control Signals
    input [ADDRESS_WIDTH-1:0] ctrl_addr,
    input [DATA_WIDTH-1:0] ctrl_wdata,
    input [(DATA_WIDTH/8)-1 : 0] ctrl_wstrb,
    input ctrl_write_req,
    input ctrl_read_req,
    output reg [DATA_WIDTH-1:0] ctrl_rdata,
    output reg ctrl_write_done,
    output reg ctrl_read_done,
    output reg [1:0] ctrl_resp,


    // Write Address
    output reg [ADDRESS_WIDTH-1:0] AWADDR,
    output reg [2:0] AWPROT,
    output reg AWVALID,
    input AWREADY,
    
    // Write Data
    output reg [DATA_WIDTH-1:0] WDATA,
    output reg [(DATA_WIDTH/8)-1 : 0] WSTRB,
    output reg WVALID,
    input WREADY,

    // Write Response
    input [1:0] BRESP,
    input BVALID,
    output reg BREADY,

    // Read Address
    output reg [ADDRESS_WIDTH-1:0] ARADDR,
    output reg [2:0] ARPROT,
    output reg ARVALID,
    input ARREADY,

    // Read Data
    input RVALID,
    output reg RREADY,
    input [DATA_WIDTH-1:0] RDATA,
    input [1:0] RRESP
    
);

    reg rst_sync1, rst_sync2;
    always @(posedge ACLK or negedge ARESETn) begin
        if(!ARESETn)begin
            rst_sync1 <= 1'b0;
            rst_sync2 <= 1'b0;
        end
        else begin 
            rst_sync1 <= 1'b1;
            rst_sync2 <= rst_sync1;
        end
    end

    //Write Address
    reg write_addr_state;
    always @(posedge ACLK) begin
        if(!rst_sync2) begin
            AWADDR <= 1'b0;
            AWVALID <= 1'b0;
            write_addr_state <= 1'b0;
            AWPROT <= 3'b001;
        end 
        else begin
            if(ctrl_write_req && !write_addr_state)begin
                write_addr_state <= 1'b1;
            end
            if(write_addr_state) begin
                AWADDR <= ctrl_addr;
                AWVALID <= 1'b1;
            end
            if(AWVALID & AWREADY) begin
                AWVALID <= 1'b0;
                write_addr_state <= 1'b0;              
            end
        end
    end

    // Write Data
    reg write_data_state;
    always @(posedge ACLK) begin
        if(!rst_sync2) begin
            WVALID <= 1'b0;
            WDATA <= 32'b0;
            WSTRB <= 4'b1111;
            write_data_state <= 1'b0;
        end 
        else begin
            if(ctrl_write_req && !write_data_state) begin 
                write_data_state <= 1'b1;
            end
            if(write_data_state) begin
                WDATA <= ctrl_wdata;
                WSTRB <= ctrl_wstrb;
                WVALID <= 1'b1;
            end
            if(WVALID && WREADY) begin
                WVALID <= 1'b0;
                write_data_state <= 1'b0;
            end
        end
    end

    // Write Response
    reg w_finish, aw_finish;
    always @(posedge ACLK)begin
        if(!rst_sync2) begin
            BREADY <= 1'b0;
            w_finish <= 1'b0;
            aw_finish <= 1'b0;
            ctrl_write_done <= 1'b0;
            ctrl_resp <= 2'b0;
        end
        else begin
            if(WREADY && WVALID) begin
                w_finish <= 1'b1;
            end
            if(AWREADY && AWVALID) begin
                aw_finish <= 1'b1;
            end
            if(aw_finish && w_finish) begin
                BREADY <= 1'b1;
            end
            if(BREADY && BVALID) begin
                ctrl_resp <= BRESP;
                ctrl_write_done <= 1'b1;
                BREADY <= 1'b0;
                w_finish <= 1'b0;
                aw_finish <= 1'b0;
            end 
            else begin ctrl_write_done <= 1'b0; end
        end
    end

    // Read Address
    reg read_addr_state;
    reg addr_sent;
    always @(posedge ACLK) begin
        if(!rst_sync2) begin
            ARADDR <= 1'b0;
            ARVALID <= 1'b0;
            read_addr_state <= 1'b0;
            ARPROT <= 3'b001;
            addr_sent <= 1'b0;
        end 
        else begin
            if(ctrl_read_req && !read_addr_state)begin
                read_addr_state <= 1'b1;
            end
            if(read_addr_state) begin
                ARADDR <= ctrl_addr;
                ARVALID <= 1'b1;
            end
            if(ARVALID && ARREADY) begin
                ARVALID <= 1'b0;
                read_addr_state <= 1'b0;     
                addr_sent <= 1'b1;         
            end
        end
    end

    // Read Data
    always @(posedge ACLK) begin
        if(!rst_sync2) begin
            RREADY <= 1'b0;
            ctrl_read_done <= 1'b0;
        end
        else begin
            if(addr_sent)begin
                RREADY <= 1'b1;
            end
            if(RREADY && RVALID && addr_sent) begin
                ctrl_rdata <= RDATA;
                ctrl_resp  <= RRESP;
                RREADY <= 1'b0;
                ctrl_read_done <= 1'b1;
                addr_sent <= 1'b0;
            end else begin 
                ctrl_read_done <= 1'b0;
            end
        end
    end
endmodule