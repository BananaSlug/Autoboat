#include "circBuffer.h"
#include "uart1.h"
#include <p33Fxxxx.h>

CircBuffer uart1RxBuffer;
CircBuffer uart1TxBuffer;

/*
 * Private functions.
 */
void startUart1Transmission();

/**
 * Initialization function for the UART1 peripheral.
 * Should be called in initialization code for the
 * model. This function configures the UART
 * for whatever baud rate is specified. It also configures two circular buffers
 * for transmission and reception.
 */
void initUart1(unsigned int brgRegister) {
	int i;

	// First initialize the necessary circular buffers.
	newCircBuffer(&uart1RxBuffer);
	newCircBuffer(&uart1TxBuffer);

	// Configure and open the port;
	// U1MODE Register
	// ==============
	U1MODEbits.UARTEN	= 0;		// Disable the port
	U1MODEbits.USIDL 	= 0;		// Stop on idle
	U1MODEbits.IREN		= 0;		// No IR decoder
	U1MODEbits.RTSMD	= 0;		// Ready to send mode (irrelevant)
	U1MODEbits.UEN		= 0;		// Only RX and TX
	U1MODEbits.WAKE		= 1;		// Enable at startup
	U1MODEbits.LPBACK	= 0;		// Disable loopback
	U1MODEbits.ABAUD	= 0;		// Disable autobaud
	U1MODEbits.URXINV	= 0;		// Normal operation (high is idle)
	U1MODEbits.PDSEL	= 0;		// No parity 8 bit
	U1MODEbits.STSEL	= 0;		// 1 stop bit
	U1MODEbits.BRGH 	= 0;		// Low speed mode

	// U1STA Register
	// ==============
	U1STAbits.URXISEL	= 2;		// RX interrupt when 3 chars are in
	U1STAbits.OERR		= 0;		// clear overun error

	U1BRG = brgRegister;			// Set the baud rate register

	// Finally setup interrupts for proper UART communication.
	IPC3bits.U1TXIP = 6;    		// Interrupt priority 6  
	IPC2bits.U1RXIP = 6;    		// Interrupt priority 6 
	IEC0bits.U1TXIE = 1; 			// Enable transmission interrupt
	IEC0bits.U1RXIE = 1; 			// Enable reception interrupt

	// Enable the port;
	U1MODEbits.UARTEN	= 1;		// Enable the port
	U1STAbits.UTXEN		= 1;		// Enable TX

}

void changeUart1BaudRate(unsigned short brgRegister) {

	unsigned char utxen = U1STAbits.UTXEN;

	// Disable the port;
	U1MODEbits.UARTEN = 0;

	// Change the BRG register to set the new baud rate
	U1BRG = brgRegister;

	// Enable the port restoring the previous transmission settings
	U1MODEbits.UARTEN	= 1;
	U1STAbits.UTXEN		= utxen;
}

/**
 * This function actually initiates transmission. It
 * attempts to start transmission with the first element
 * in the queue if transmission isn't already proceeding.
 * Once transmission starts the interrupt handler will
 * keep things moving from there. The buffer is checked
 * for new data and the transmission buffer is checked that
 * it has room for new data before attempting to transmit.
 */
void startUart1Transmission() {
	if (getLength(&uart1TxBuffer) > 0 && !U1STAbits.UTXBF) {
		U1TXREG = readFront(&uart1TxBuffer);
	}
}

/**
 * This function supplements the uart1EnqueueData() function by also
 * providing an interface that only enqueues a single byte.
 */
void uart1EnqueueByte(unsigned char datum) {
	writeBack(&uart1TxBuffer, datum);
	startUart1Transmission();
}

/**
 * This function enqueues all bytes in the passed data character array according to the passed
 * length.
 */
void uart1EnqueueData(unsigned char *data, unsigned char length) {
	unsigned char g;

	for (g = 0; g < length; g++) {
		writeBack(&uart1TxBuffer,data[g]);
	}

	startUart1Transmission();
}

void __attribute__((__interrupt__, no_auto_psv)) _U1RXInterrupt(void) {

	// Keep receiving new bytes while the buffer has data.
	while (U1STAbits.URXDA == 1) {
		writeBack(&uart1RxBuffer, (unsigned char)U1RXREG);
	}

	// Clear buffer overflow bit if triggered
	if (U1STAbits.OERR == 1) {
		U1STAbits.OERR = 0;
	}

	// Clear the interrupt flag
	IFS0bits.U1RXIF = 0;
}

/**
 * This is the interrupt handler for UART1 transmission.
 * It is called after at least one byte is transmitted (
 * depends on UTXISEL<1:0> as to specifics). This function
 * therefore keeps adding bytes to transmit if there're more
 * in the queue.
 */
void __attribute__((__interrupt__, no_auto_psv)) _U1TXInterrupt(void) {
	startUart1Transmission();

	// Clear the interrupt flag
	IFS0bits.U1TXIF = 0;
}
