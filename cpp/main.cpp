#include <stdio.h>
#include "axi_uart.h"
using std::string;

CAxiUart AXI;
const char** ArgV;

//=============================================================================
// get_device_name() - Returns the name of the serial device, as read from
//                     an environment variable
//=============================================================================
string get_device_name()
{
    const char* evname = "axi_uart_device";

    // Fetch the environment variable that contains our device name
    char* ev = getenv(evname);
    
    // If that variable doesn't exist, tell the user
    if (ev == nullptr)
    {
        fprintf(stderr, "missing environment variable '%s'\n", evname);
        exit(1);
    }

    // Hand the device name to the caller
    return ev;
}
//=============================================================================


//=============================================================================
// help() - Show the command line ujsage of this program
//=============================================================================
void help()
{
    printf("usage: axi_uart_demo read <address>\n");
    printf("       axi_uart_demo write <address> <data>\n");
    printf("\n<address> and <data> can be in hex or decimal\n");
    exit(0);
}
//=============================================================================


//=============================================================================
// axi_read() - Reads the command line and performs an AXI-read transaction
//=============================================================================
void axi_read()
{
    uint32_t data;

    // Make sure the user gave us an address on the command line
    if (ArgV[2] == nullptr) help();

    // Fetch the AXI address we want to read from
    uint32_t address = strtoul(ArgV[2], 0, 0);   

    // Fetch the device name of our serial port
    string device = get_device_name();

    // Connect to the FPGA via a serial port
    if (!AXI.connect(device, 115200))
    {
        printf("%s not found or no permissions\n", device.c_str());
        exit(1);        
    }

    // Perform the AXI transaction
    int error = AXI.read(address, &data);

    // If an AXI read-error occured, show the error code
    if (error) printf("Error: read-response = %i\n", error);

    // Otherwise, display the data value we read
    else printf("%u (0x%08X)\n", data, data);
}
//=============================================================================


//=============================================================================
// axi_write() - Reads the command line and performs an AXI-write transaction
//=============================================================================
void axi_write()
{
    // Make sure the user gave us an address on the command line
    if (ArgV[2] == nullptr) help();

    // Make sure the user gave us data on the command line
    if (ArgV[3] == nullptr) help();

    // Fetch the AXI address we want to write to
    uint32_t address = strtoul(ArgV[2], 0, 0);   

    // Fetch the data we want to write to that address
    uint32_t data = strtoul(ArgV[3], 0, 0);

    // Fetch the device name of our serial port
    string device = get_device_name();

    // Connect to the FPGA via a serial port
    if (!AXI.connect(device, 115200))
    {
        printf("%s not found or no permissions\n", device.c_str());
        exit(1);        
    }

    // Perform the AXI transaction
    int error = AXI.write(address, data);

    // If an AXI read-error occured, show the erro code
    if (error) printf("Error: write-response = %i\n", error);
}
//=============================================================================



//=============================================================================
// strcpyToAxi() - like strcpy, but the destination is in AXI address space
//=============================================================================
void strcpyToAxi(uint32_t axiAddress, const char* src)
{
    // Loop until we find the nul-byte that terminates the string
    while (true)
    {
        // Fetch the next four bytes of the string
        uint32_t data = (src[3] << 24) | (src[2] << 16) | (src[1] << 8 ) | src[0];
        
        // Write them to the specified AXI address
        AXI.write(axiAddress, data);

        // If any of those four bytes was nul, we're done
        if (src[0] == 0 || src[1] == 0 || src[2] == 0 || src[3] == 0) break;

        // Point to the next 32-bit word of AXI address space
        axiAddress += 4;

        // And point to the next four bytes of the input string
        src += 4;
    }
}
//=============================================================================


//=============================================================================
// main() - Command line is:
//=============================================================================
int main(int argc, const char** argv)
{
    // Fetch the name of the serial device we use to talk to AXI
    string device = get_device_name();

    // Connect to the FPGA via a serial port
    if (!AXI.connect(device, 115200))
    {
        printf("%s not found or no permissions\n", device.c_str());
        exit(1);        
    }

    if (argv[1] == NULL) 
    {
        printf("Missing AXI address parameter on command line\n");
        exit(1);        
    }

    uint32_t axiAddress=strtoul(argv[1], 0, 0);

    if (argv[2] == NULL)
    {
        printf("Missing string parameter on command line\n");
        exit(1);
    }

    strcpyToAxi(axiAddress, argv[2]);

    // Tell the OS that all is well
    return 0;
}
//=============================================================================

