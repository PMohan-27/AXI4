interface axi_lite_if #(parameter  int DATA_WIDTH = 32, parameter int ADDRESS_WIDTH = 32)(
    input logic ACLK,
    input logic ARESETn
);  
    // Write Address
    logic [ADDRESS_WIDTH-1:0] AWADDR;
    logic [2:0] AWPROT;
    logic AWVALID;
    logic AWREADY;
    
    // Write Data
    logic [DATA_WIDTH-1:0] WDATA;
    logic [(DATA_WIDTH/8)-1 : 0] WSTRB;
    logic WVALID;
    logic WREADY;

    // Write Response
    logic [1:0] BRESP;
    logic BVALID;
    logic BREADY;

    // Read Address
    logic [ADDRESS_WIDTH-1:0] ARADDR;
    logic [2:0] ARPROT;
    logic ARVALID;
    logic ARREADY;

    // Read Data
    logic RVALID;
    logic RREADY;
    logic [DATA_WIDTH-1:0] RDATA;
    logic [1:0] RRESP;

    modport master 
    (
        // Write address
        output AWADDR, AWPROT, AWVALID,
        input  AWREADY,

        // Write data
        output WDATA, WSTRB, WVALID,
        input  WREADY,

        // Write response
        input  BRESP, BVALID,
        output BREADY,

        // Read address
        output ARADDR, ARPROT, ARVALID,
        input  ARREADY,

        // Read data
        input  RDATA, RRESP, RVALID,
        output RREADY,

        // Clock / reset
        input ACLK, ARESETn
    );
    modport slave 
    (
        // Write address
        input AWADDR, AWPROT, AWVALID,
        output  AWREADY,

        // Write data
        input WDATA, WSTRB, WVALID,
        output  WREADY,

        // Write response
        output  BRESP, BVALID,
        input BREADY,

        // Read address
        input ARADDR, ARPROT, ARVALID,
        output  ARREADY,

        // Read data
        output  RDATA, RRESP, RVALID,
        input RREADY,

        // Clock / reset
        input ACLK, ARESETn
    );


endinterface