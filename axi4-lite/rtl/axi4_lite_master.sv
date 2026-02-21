module axi4_lite_master #(parameter  int DATA_WIDTH = 32, parameter int ADDRESS_WIDTH = 32)(

    // Control Signals
    input logic [ADDRESS_WIDTH-1:0] ctrl_waddr,
    input logic [ADDRESS_WIDTH-1:0] ctrl_raddr,
    input logic [DATA_WIDTH-1:0] ctrl_wdata,
    input logic [(DATA_WIDTH/8)-1 : 0] ctrl_wstrb,
    input logic ctrl_write_req,
    input logic ctrl_read_req,
    output logic [DATA_WIDTH-1:0] ctrl_rdata,
    output logic ctrl_write_done,
    output logic ctrl_read_done,
    output logic [1:0] ctrl_bresp,
    output logic [1:0] ctrl_rresp,


    axi_lite_if.master  axi
    
);
    typedef enum logic[1:0] { IDLE, SENDING, AWAITING } state;
    state write_state, read_state;
    logic aw_sent, w_sent;
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

    
    always_ff @(posedge axi.ACLK) begin 
        if(!rst_sync2) begin 
            aw_sent <= '0;
            w_sent <= '0;
            write_state <= IDLE;
        end 
        else begin
            case(write_state) 
                IDLE: if(ctrl_write_req == 1'b1) write_state <= SENDING; 
                SENDING: if(aw_sent && w_sent) write_state <= AWAITING;
                AWAITING: if(axi.BREADY && axi.BVALID) write_state <= IDLE;
                default: write_state <= IDLE;
            endcase
        end
    end

    always_ff @(posedge axi.ACLK) begin
        if(!rst_sync2) begin
            axi.AWADDR <= '0;
            axi.AWVALID <= '0;
            axi.WDATA <= '0;
            axi.WVALID <= '0;
            axi.BREADY <= '0;
            axi.AWPROT <= '0;
            axi.WSTRB <= '1;
            ctrl_write_done <= '0;
        end
        else begin
            case(write_state) 
                SENDING: begin
                    if(!axi.AWVALID && !aw_sent)begin
                        axi.AWADDR <= ctrl_waddr;
                        axi.AWPROT <= 3'b001; //priviliged 
                        axi.AWVALID <= 1'b1;
                    end

                    if(!axi.WVALID && !w_sent) begin
                        axi.WDATA <= ctrl_wdata;
                        axi.WSTRB <= ctrl_wstrb;
                        axi.WVALID <= 1'b1;
                    end
                    if(axi.AWVALID && axi.AWREADY) begin
                        axi.AWVALID <= 1'b0;
                        aw_sent <= 1'b1;
                    end
                    if(axi.WVALID && axi.WREADY) begin
                        axi.WVALID <= 1'b0;
                        w_sent <= 1'b1;
                    end
                end
                AWAITING: begin
                    if(!axi.BREADY && !ctrl_write_done) begin
                        axi.BREADY <= 1'b1;
                    end
                    if(axi.BREADY && axi.BVALID) begin
                        axi.BREADY <= 1'b0;
                        ctrl_write_done <= 1'b1;
                        ctrl_bresp <= axi.BRESP;
                        w_sent <= 1'b0;
                        aw_sent <= 1'b0;
                    end
                end
                IDLE: begin
                    ctrl_write_done <= 1'b0;
                end
                default: begin
                    axi.AWADDR <= '0;
                    axi.WDATA <= '0;
                    ctrl_write_done <= '0;
                    
                end
            endcase
        end
    end

    always_ff @(posedge axi.ACLK) begin 
        if(!rst_sync2) begin 
            read_state <= IDLE;
        end 
        else begin
            case(read_state) 
                IDLE: if(ctrl_read_req == 1'b1) read_state <= SENDING; 
                SENDING: if(axi.ARVALID && axi.ARREADY) read_state <= AWAITING;
                AWAITING: if(axi.RREADY && axi.RVALID) read_state <= IDLE;
                default: read_state <= IDLE;
            endcase
        end
    end


    always_ff @(posedge axi.ACLK) begin
        if(!rst_sync2) begin
            ctrl_rresp <= '0;
            ctrl_rdata <= '0;
            ctrl_read_done <= '0;
            axi.ARADDR <= '0;
            axi.ARVALID <= '0;
            axi.RREADY <= '0;
            axi.ARPROT <= '0;
        end
        else begin 
            case(read_state) 
                SENDING: begin
                    if(!axi.ARVALID) begin
                        axi.ARVALID <= 1'b1;
                        axi.ARADDR <= ctrl_raddr;
                        axi.ARPROT <= '0;
                    end
                    if(axi.ARVALID  && axi.ARREADY) begin
                        axi.ARVALID <= 1'b0;
                        axi.RREADY <= 1'b1;
                    end
                end
                AWAITING: begin
                    if(axi.RREADY && axi.RVALID) begin
                        ctrl_rresp <= axi.RRESP;
                        ctrl_rdata <= axi.RDATA;
                        ctrl_read_done <= 1'b1;
                        axi.RREADY <= 1'b0;
                    end
                end
                IDLE: begin
                    ctrl_read_done <= 1'b0;
                end
                default: begin 
                    axi.ARVALID <= '0;
                    ctrl_read_done <= '0;
                end
                
            endcase
        end
        
    end
endmodule