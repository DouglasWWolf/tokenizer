// The width of AXI address bus, in bits
`define IPC_AXI_ADDR_WIDTH     64

// The width of the RAM data bus, in bits
`define IPC_RAM_DATA_WIDTH     256

// The width of a single token in bits.  For efficiency, should match IPC_RAM_DATA_WIDTH
`define IPC_TOKEN_WIDTH        256

// The location in RAM that contains the parsed tokens of a host-to-fpga message
`define IPC_H2F_TOKENS_ADDR    64'hC000_1000

// The maximum number of tokens in a host-to-fpga message
`define IPC_MAX_INPUT_TOKENS   16

// This should be greater or equal to IPC_MAX_INPUT_TOKENS
`define IPC_DEFAULT_FIFO_DEPTH 16
