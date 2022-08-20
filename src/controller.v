`timescale 1ns / 1ps

//====================================================================================
//                        ------->  Revision History  <------
//====================================================================================
//
//   Date     Who   Ver  Changes
//====================================================================================
// 10-Aug-22  DWW  1000  Initial creation
//====================================================================================


//====================================================================================
//                    Parameter and port declaration
//====================================================================================
module controller#
(
    parameter AXI_ADDR_WIDTH  = 32
)
(
    input  clk, resetn,
    input  BUTTON,
    input  IDLE,

    output[AXI_ADDR_WIDTH-1:0] STR_ADDR, OUT_ADDR,
    output reg START
);
//====================================================================================


reg[3:0] state;

assign STR_ADDR = 32'hC000_0000;
assign OUT_ADDR = 32'hC000_0100;

always @(posedge clk) begin

    START <= 0;

    if (resetn == 0) begin
        state <= 0;
    end else case (state)

    0:  if (BUTTON) begin
            START    <= 1;
            state    <= state + 1;
        end

    1:  if (IDLE) begin
            state <= 0;
        end

    endcase
end


endmodule
