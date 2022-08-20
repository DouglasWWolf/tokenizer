//============================================================================
// axi_uart.cpp - Implements an API for reading/writing AXI registers via UART
//============================================================================
#include <unistd.h>
#include <string.h>
#include "axi_uart.h"
using std::string;

enum {CMD_READ = 1, CMD_WRITE = 2};

//============================================================================
// write_word() - Writes the specified word, big-endian, at the specified
//                address
//============================================================================
static void write_word(uint32_t word, unsigned char* ptr)
{
    ptr[0] = (unsigned char)(word >> 24);
    ptr[1] = (unsigned char)(word >> 16);
    ptr[2] = (unsigned char)(word >>  8);
    ptr[3] = (unsigned char)(word      );
}
//============================================================================


//============================================================================
// connect() - Opens a connection to the serial port
//============================================================================
bool CAxiUart::connect(string device, uint32_t baud)
{
    // We want serial read/write to be a blocking operation
    sp_.setDefaultReadTimeout(SP_NO_TIMEOUT);
    
    // Open a connection to the specified serial port
    return sp_.open(device, baud);
}
//============================================================================


//============================================================================
// read() - Performs an AXI read transaction
//
// Passed: address  = AXI address to read from
//         p_result = Address where the data read should be stored
//
// Returns: AXI-read-response value. 0 = OKAY
//============================================================================
int CAxiUart::read(uint32_t address, uint32_t* p_result)
{
    unsigned char command[5];
    unsigned char response[5];

    // Fill in the first byte of the buffer with a READ command
    command[0] = CMD_READ;

    // Fill in the next 4 bytes of the buffer with our AXI address
    write_word(address, command+1);

    // Write the AXI-read command to the serial port
    sp_.write(command, sizeof command);

    // Fetch the response
    sp_.read(response, sizeof response);

    // Fill in the caller's result field
    *p_result = response[1] << 24
              | response[2] << 16
              | response[3] <<  8
              | response[4];

    // And return the error code to the caller
    return response[0];
}
//============================================================================


//============================================================================
// write() - Performs an AXI write transaction
//
// Passed: address = AXI address to write to
//         data    = Data to be written to the specified address
//
// Returns: AXI-write-response value. 0 = OKAY
//============================================================================
int CAxiUart::write(uint32_t address, uint32_t data)
{
    unsigned char command[9];
    unsigned char response[1];

    // Fill in the first byte of the buffer with a WRITE command
    command[0] = CMD_WRITE;

    // Fill in the next 4 bytes of the buffer with our AXI address
    write_word(address, command+1);

    // Fill in the next 4 bytes of the buffer with the data we want to write
    write_word(data, command+5);

    // Write the AXI command to the serial port
    sp_.write(command, sizeof command);

    // Fetch the response
    sp_.read(response, sizeof response);

    // And return the error code to the caller
    return response[0];
}
//============================================================================


//============================================================================
// reset() - Forces the FPGA serial input buffer into a known-good state
//============================================================================
void CAxiUart::reset()
{
    const char* reset_string = "XXXXXXXXXXXXXXXX";

    // Send the reset string to the FPGA
    sp_.write(reset_string, strlen(reset_string));

    // Wait for the FPGA serial-buffer manager to timeout
    usleep(150000);

    // And throw away any response bytes
    sp_.drainInput(100);
}
//============================================================================



