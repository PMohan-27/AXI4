module axi4_lite #(parameter DATA_WIDTH = 32, ADDRESS_WIDTH = 32)(
    // Global
    input ACLK,
    input ARESETn,

    // Control Signals
    input [ADDRESS_WIDTH-1:0] ctrl_addr,
    input [DATA_WIDTH-1:0] ctrl_wdata,
    input ctrl_write_en,
    input ctrl_read_en,
    output [DATA_WIDTH-1:0] ctrl_rdata,
    output ctrl_done,
    output [2:0] ctrl_resp,


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
    reg addr_write_state;
    always @(posedge ACLK)begin
        AWPROT <= 3'b001; // priviliged for now
        if(!rst_sync2)begin
            AWVALID <= 1'b0;
            addr_write_state <= 1'b0;
        end
        else begin 
            if(ctrl_write_en && !addr_write_state) begin
                AWADDR <= ctrl_addr;
                AWVALID <= 1'b1;
                addr_write_state <= 1'b1;
            end
            if(AWVALID && AWREADY) begin
                AWVALID <= 1'b0;
                addr_write_state <= 1'b0;
            end
        end
    end

    //Write Data
    reg data_write_state;
    always @(posedge ACLK) begin
        WSTRB <= 4'b1111; // full strb for now
        if(!rst_sync2)begin
            WVALID <= 1'b0;
            data_write_state <= 1'b0;
        end
        else begin 
            if(ctrl_write_en && !data_write_state) begin
                WDATA <= ctrl_wdata;
                WVALID <= 1'b1;
                data_write_state <= 1'b1;
            end
            if(WVALID && WREADY) begin
                WVALID <= 1'b0;
                data_write_state <= 1'b0;
            end
        end
    end

    // Write Response
    reg aw_done, w_done;
    always @(posedge ACLK) begin
        if(!rst_sync2) begin
            BREADY <= 1'b0;
            ctrl_done <= 1'b0;
            aw_done <= 1'b0;
            w_done <= 1'b0;
        end
        else begin
            if(WVALID && WREADY) w_done <= 1'b1;
            if(AWVALID && AWREADY) aw_done <= 1'b1;

            if(aw_done && w_done) begin
                BREADY <= 1'b1;
            end

            if(BREADY && BVALID) begin
                ctrl_resp <= BRESP;
                ctrl_done <= 1'b1;
                BREADY <= 1'b0;
                aw_done <= 1'b0;
                w_done <= 1'b0;
            end
            else begin
                ctrl_done <= 1'b0;
            end
        end
    end
    
endmodule