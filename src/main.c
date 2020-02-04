#include "stm32f2xx.h"

// Quick and dirty delay
static void delay (unsigned int time) {
    for (unsigned int i = 0; i < time; i++)
        for (volatile unsigned int j = 0; j < 2000; j++);
}


int main (void) {
    // Turn on the GPIOC peripheral
    RCC->AHB1ENR |= RCC_AHB1ENR_GPIOBEN;

    // Put pin 0 in general purpose output mode
    GPIOB->MODER |= GPIO_MODER_MODE0_0;

    while (1) {
        // Reset the state of pin 13 to output low
        GPIOB->BSRR = GPIO_BSRR_BR0;

        delay(500);

        // Set the state of pin 13 to output high
        GPIOB->BSRR = GPIO_BSRR_BS0;

        delay(500);
    }

    // Return 0 to satisfy compiler
    return 0;
}
