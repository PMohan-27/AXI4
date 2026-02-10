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
    output reg ctrl_done,
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
            if(ctrl_write_req)begin
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
            if(ctrl_write_req) begin 
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
endmodule