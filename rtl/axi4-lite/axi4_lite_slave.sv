module axi4_lite_slave #(parameter DATA_WIDTH = 32, ADDRESS_WIDTH = 32)(
    output logic [ADDRESS_WIDTH-1:0] slave_raddr,
    output logic [ADDRESS_WIDTH-1:0] slave_waddr,
    output logic [DATA_WIDTH-1:0] slave_wdata,
    output logic [(DATA_WIDTH/8)-1 : 0] slave_wstrb,
    output logic send_slave_write,
    output logic send_slave_read,
    input logic [DATA_WIDTH-1:0] slave_rdata,
    input logic slave_write_done,
    input logic slave_read_done,
    input logic [1:0] slave_rresp,
    input logic [1:0] slave_bresp


    axi_lite_if.slave axi
);
    typedef enum logic [1:0] { AWAIT_MASTER, AWAIT_PERIPHERAL, RESPOND } state;
    state write_state, read_state;
    logic aw_recieved, w_recieved;

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
            write_state <= AWAIT_MASTER;
            aw_recieved <= '0;
            w_recieved <= '0;
        end 
        else begin
            case(write_state)
            AWAIT_MASTER: if(w_recieved && aw_recieved) write_state <= AWAIT_PERIPHERAL;
            AWAIT_PERIPHERAL: if(slave_write_done) write_state <= RESPOND;
            RESPOND: if(axi.BREADY && axi.BVALID) write_state <= AWAIT_MASTER;
            default: write_state <= AWAIT_MASTER;
            endcase
        end
    end

    always_ff @(posedge axi.ACLK) begin
        if(!rst_sync2) begin
            axi.AWREADY <= '0;
            axi.WREADY <= '0;
            axi.BRESP <= '0;
            axi.BVALID <= '0;
            slave_waddr <= '0;
            slave_wdata <= '0;
            slave_wstrb <= '0;
            send_slave_write <= '0;
        end
        else begin
            case(write_state) 
                AWAIT_MASTER: begin
                    if(!axi.AWREADY && !aw_recieved) axi.AWREADY <= 1'b1;
                    if(!axi.WREADY && !w_recieved) axi.WREADY <= 1'b1;


                    if(axi.AWREADY && axi.AWVALID) begin
                        aw_recieved <= 1'b1;
                        slave_waddr <= axi.AWADDR;
                        axi.AWREADY <= 1'b0;
                    end

                    if(axi.WREADY && axi.WVALID) begin
                        w_recieved <= 1'b1;
                        slave_wdata <= axi.WDATA;
                        slave_wstrb <= axi.WSTRB;
                        axi.WREADY <= 1'b0;
                    end

                    if(aw_recieved && w_recieved) begin
                        send_slave_write <= 1'b1;
                    end
                end
                AWAIT_PERIPHERAL: begin
                    if(send_slave_write) send_slave_write <= 1'b0;
                    if(slave_write_done) begin
                        axi.BRESP <=slave_bresp;
                        axi.BVALID <= 1'b1;
                    end
                end
                RESPOND: begin
                    if(axi.BVALID && axi.BREADY) begin
                        axi.BVALID <= 1'b0;
                        aw_recieved <= 1'b0;
                        w_recieved <= 1'b0;
                    end
                end
            endcase
        end
    end


    always_ff @(posedge axi.ACLK) begin
        if(!rst_sync2) begin
            read_state <= AWAIT_MASTER;
        end
        else begin
            case(read_state) 
                AWAIT_MASTER: if(axi.ARREADY && axi.ARVALID) read_state <= AWAIT_PERIPHERAL;
                AWAIT_PERIPHERAL: if(slave_read_done) read_state <= RESPOND;
                RESPOND: if(axi.RVALID && axi.RREADY) read_state <= AWAIT_MASTER;
            endcase
        end
    end



    always_ff @(posedge axi.ACLK) begin
        if(!rst_sync2)begin
            axi.RVALID <= '0;
            axi.ARREADY <= '0;
            axi.RDATA <= '0;
        end
        else begin

        end
    end

endmodule
