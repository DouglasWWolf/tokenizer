`timescale 1ns / 1ps

//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//               This core is a demonstration of an AXI4-Lite slave
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>


//====================================================================================
//                        ------->  Revision History  <------
//====================================================================================
//
//   Date     Who   Ver  Changes
//====================================================================================
// 18-Aug-22  DWW  1000  Initial creation
//====================================================================================


module fancy_blink #(parameter LED_COUNT = 4, CLOCK_FREQ = 100000000)
(
    input clk, resetn,

    output reg [LED_COUNT-1:0] LED,

    //================== This is an AXI4-Lite slave interface ==================
        
    // "Specify write address"              -- Master --    -- Slave --
    input[31:0]                             S_AXI_AWADDR,   
    input                                   S_AXI_AWVALID,  
    output                                                  S_AXI_AWREADY,
    input[2:0]                              S_AXI_AWPROT,

    // "Write Data"                         -- Master --    -- Slave --
    input[31:0]                             S_AXI_WDATA,      
    input                                   S_AXI_WVALID,
    input[3:0]                              S_AXI_WSTRB,
    output                                                  S_AXI_WREADY,

    // "Send Write Response"                -- Master --    -- Slave --
    output[1:0]                                             S_AXI_BRESP,
    output                                                  S_AXI_BVALID,
    input                                   S_AXI_BREADY,

    // "Specify read address"               -- Master --    -- Slave --
    input[31:0]                             S_AXI_ARADDR,     
    input                                   S_AXI_ARVALID,
    input[2:0]                              S_AXI_ARPROT,     
    output                                                  S_AXI_ARREADY,

    // "Read data back to master"           -- Master --    -- Slave --
    output[31:0]                                            S_AXI_RDATA,
    output                                                  S_AXI_RVALID,
    output[1:0]                                             S_AXI_RRESP,
    input                                   S_AXI_RREADY
    //==========================================================================
 );

    //==========================================================================
    // We'll communicate with the AXI4-Lite Slave core with these signals.
    //==========================================================================
    // AXI Slave Handler Interface for write requests
    wire[31:0]  ashi_waddr;     // Input:  Write-address
    wire[31:0]  ashi_wdata;     // Input:  Write-data
    wire        ashi_write;     // Input:  1 = Handle a write request
    reg[1:0]    ashi_wresp;     // Output: Write-response (OKAY, DECERR, SLVERR)
    wire        ashi_widle;     // Output: 1 = Write state machine is idle

    // AXI Slave Handler Interface for read requests
    wire[31:0]  ashi_raddr;     // Input:  Read-address
    wire        ashi_read;      // Input:  1 = Handle a read request
    reg[31:0]   ashi_rdata;     // Output: Read data
    reg[1:0]    ashi_rresp;     // Output: Read-response (OKAY, DECERR, SLVERR);
    wire        ashi_ridle;     // Output: 1 = Read state machine is idle
    //==========================================================================

    genvar x;

    // We're going to support 20 different blink-rate divisors
    localparam DIVISORS = 20;

    // The state of our two state machines
    reg[2:0] read_state, write_state;

    // The state machines are idle when they're in state 0 when their "start" signals are low
    assign ashi_widle = (ashi_write == 0) && (write_state == 0);
    assign ashi_ridle = (ashi_read  == 0) && (read_state  == 0);

    // This is where we'll store the AXI register data
    reg[31:0] axi_register[0:LED_COUNT-1];
    
    // These are the valid values for ashi_rresp and ashi_wresp
    localparam OKAY   = 0;
    localparam SLVERR = 2;
    localparam DECERR = 3;

    // These are precomputed timer-reload values for a given divisor
    wire[31:0] reload_precalc[1:DIVISORS];
    for (x=1; x<=DIVISORS; x=x+1) assign reload_precalc[x] = CLOCK_FREQ/x;


    reg[LED_COUNT-1:0] is_led_fixed, led_fixed_at;
    reg[31:0] counter[0:LED_COUNT-1], reload[0:LED_COUNT-1];

    // An AXI slave is gauranteed a minimum of 128 bytes of address space
    // (128 bytes is 32 32-bit registers)
    localparam ADDR_MASK = 7'h7F;

    // The index of the register that the master wants to read or write to
    reg[7:0] register_rindex, register_windex;

    //==========================================================================
    // This state machine handles AXI read-requests
    //
    // A read-request begins when "ashi_read" goes high
    //
    // When "ashi_read" goes high:
    //    ashi_raddr = The address being read from
    //
    // When the state machine returns to idle:
    //    ashi_rdata = The data to hand hand back to the AXI master
    //    ashi_wresp = the AXI BRESP: OKAY, DECERR, or SLVERR
    //    
    //==========================================================================
    always @(posedge clk) begin

        // If we're in reset, initialize important registers
        if (resetn == 0) begin
            read_state <= 0;

        // If we're not in reset, and a read-request has occured...        
        end else case (read_state)
        
        0:  if (ashi_read) begin
                register_rindex <= (ashi_raddr & ADDR_MASK) >> 2;
                read_state      <= 1;
            end

        1:  begin
                if (register_rindex >= LED_COUNT)
                    ashi_rresp <= DECERR;
                else begin
                    ashi_rdata <= axi_register[register_rindex];
                    ashi_rresp <= OKAY;
                end
                read_state <= 0;
            end
        endcase
    end
    //==========================================================================



    //==========================================================================
    // This state machine handles AXI write-requests
    //
    // A write-request begins when "ashi_write" goes high
    //
    // When "ashi_write" goes high:
    //    ashi_waddr = The address being written data
    //    ashi_wdata = The data being written
    //
    // When the state machine returns to idle:
    //    ashi_wresp = the AXI BRESP: OKAY, DECERR, or SLVERR
    //    
    //==========================================================================
    always @(posedge clk) begin

        // If we're in reset, initialize important registers
        if (resetn == 0) begin
            write_state  <= 0;
            is_led_fixed <= -1;
            led_fixed_at <= 0;

        // If we're not in reset, and a write-request has occured...        
        end else case (write_state)
        
        0:  if (ashi_write) begin
                register_windex <= (ashi_waddr & ADDR_MASK) >> 2;
                write_state     <= 1;
            end

        1:  begin

                if (register_windex >= LED_COUNT)
                    ashi_wresp <= DECERR;
                else begin
                    ashi_wresp <= OKAY;
                    axi_register[register_windex] <= ashi_wdata;
                    if (ashi_wdata == 0 || ashi_wdata > DIVISORS) begin
                        is_led_fixed[register_windex] <= 1;
                        led_fixed_at[register_windex] <= (ashi_wdata != 0);
                    end else begin
                        is_led_fixed[register_windex] <= 0;
                        reload[register_windex] = reload_precalc[ashi_wdata];
                    end
                end

                write_state <= 0;
            end
        endcase
    end
    //==========================================================================

    //==========================================================================
    // This state machine manages LEDs
    //==========================================================================
    for (x=0; x<LED_COUNT; x=x+1) begin
        always @(posedge clk) begin 
            if (resetn == 0)
                LED[x] <= 0;
            else begin
                // If the LED has a fixed value...
                if (is_led_fixed[x])

                    // Output that fixed value.
                    LED[x] <= led_fixed_at[x];
                
                // Otherwise, if it's counter has reached 0...
                else if (counter[x] == 0) begin
                    
                    // Invert the state of the LED...
                    LED[x] <= ~LED[x];
                    
                    // And reload the counter for this LED
                    counter[x] <= reload[x];

                // Otherwise, this LED is still counting down
                end else counter[x] <= counter[x] - 1;
            end
        end
    end
    //==========================================================================


    //==========================================================================
    // This connects us to an AXI4-Lite slave core
    //==========================================================================
    axi4_lite_slave axi_slave
    (
        .clk            (clk),
        .resetn         (resetn),
        
        // AXI AW channel
        .AXI_AWADDR     (S_AXI_AWADDR),
        .AXI_AWVALID    (S_AXI_AWVALID),   
        .AXI_AWPROT     (S_AXI_AWPROT),
        .AXI_AWREADY    (S_AXI_AWREADY),
        
        // AXI W channel
        .AXI_WDATA      (S_AXI_WDATA),
        .AXI_WVALID     (S_AXI_WVALID),
        .AXI_WSTRB      (S_AXI_WSTRB),
        .AXI_WREADY     (S_AXI_WREADY),

        // AXI B channel
        .AXI_BRESP      (S_AXI_BRESP),
        .AXI_BVALID     (S_AXI_BVALID),
        .AXI_BREADY     (S_AXI_BREADY),

        // AXI AR channel
        .AXI_ARADDR     (S_AXI_ARADDR), 
        .AXI_ARVALID    (S_AXI_ARVALID),
        .AXI_ARPROT     (S_AXI_ARPROT),
        .AXI_ARREADY    (S_AXI_ARREADY),

        // AXI R channel
        .AXI_RDATA      (S_AXI_RDATA),
        .AXI_RVALID     (S_AXI_RVALID),
        .AXI_RRESP      (S_AXI_RRESP),
        .AXI_RREADY     (S_AXI_RREADY),

        // ASHI write-request registers
        .ASHI_WADDR     (ashi_waddr),
        .ASHI_WDATA     (ashi_wdata),
        .ASHI_WRITE     (ashi_write),
        .ASHI_WRESP     (ashi_wresp),
        .ASHI_WIDLE     (ashi_widle),

        // AMCI-read registers
        .ASHI_RADDR     (ashi_raddr),
        .ASHI_RDATA     (ashi_rdata),
        .ASHI_READ      (ashi_read ),
        .ASHI_RRESP     (ashi_rresp),
        .ASHI_RIDLE     (ashi_ridle)
    );
    //==========================================================================

endmodule






