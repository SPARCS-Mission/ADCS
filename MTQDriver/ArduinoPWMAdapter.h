#ifndef ARDUINO_PWM_ADAPTER_H
#define ARDUINO_PWM_ADAPTER_H

#include <Arduino.h>

/**
 * @class ArduinoPWMAdapter
 * @brief Hardware adapter class to output PWM signals on an Arduino pin.
 *
 * This class provides a simple interface to send PWM signals to a specified
 * Arduino digital pin using the built-in `analogWrite()` function.
 * It abstracts Arduino hardware details, enabling separation of PWM logic
 * and hardware-specific implementation.
 */
class ArduinoPWMAdapter {
private:
    /**
     * @brief Arduino pin number used for PWM output.
     */
    int pin;

public:
    /**
     * @brief Constructor: Initializes the specified pin for PWM output.
     * 
     * Configures the given pin as an OUTPUT to prepare it for PWM signaling.
     * 
     * @param pwmPin Arduino digital pin number supporting PWM output.
     */
    ArduinoPWMAdapter(int pwmPin) : pin(pwmPin) {
        pinMode(pin, OUTPUT);
    }

    /**
     * @brief Writes a PWM value to the hardware pin.
     * 
     * Sends a PWM duty cycle value (0-255) to the configured Arduino pin
     * using the built-in `analogWrite()` function.
     * 
     * @param pwmValue PWM duty cycle (0 = off, 255 = fully on).
     */
    void write(int pwmValue) {
        analogWrite(pin, pwmValue);
    }
};

#endif
