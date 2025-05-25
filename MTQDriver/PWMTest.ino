#include <Arduino.h>
#include "PWMController.h"
#include "ArduinoPWMAdapter.h"

// Pin to output PWM signal on (must support PWM)
const int pwmPin = 7;

// Instantiate the PWM logic controller object
PWMController pwmCtrl;

// Instantiate the hardware adapter for Arduino PWM output
ArduinoPWMAdapter pwmOut(pwmPin);

/**
 * @brief Arduino setup function, runs once at startup.
 *
 * Initializes serial communication and prints instructions
 * to the user via Serial Monitor.
 */
void setup() {
    Serial.begin(9600);
    Serial.setTimeout(100);  // Short timeout to prevent unwanted input delays

    Serial.println("PWM Controller Ready.");
    Serial.println("Commands:");
    Serial.println("  0 - Stop");
    Serial.println("  1 - Start with last value");
    Serial.println("  2–100 - Set PWM % (also starts)");
}

/**
 * @brief Main loop function, runs repeatedly.
 *
 * Checks for user input via Serial, interprets commands,
 * and updates the PWMController and hardware PWM output accordingly.
 */
void loop() {
    // Check if there is any data available on Serial
    if (Serial.available()) {
        // Read input until newline and trim whitespace
        String inputStr = Serial.readStringUntil('\n');
        inputStr.trim();

        // Ignore empty input
        if (inputStr.length() == 0) return;

        // Convert input string to integer (for command processing)
        int input = inputStr.toInt();

        if (inputStr == "1110") {
            // Stop PWM output and immediately turn off hardware PWM
            pwmCtrl.stop();
            pwmOut.write(0);
            Serial.println("PWM Stopped.");
        } else if (input == 1111) {
            // Start PWM output using last stored value
            pwmCtrl.start();
            pwmOut.write(pwmCtrl.getPwmValue());
            Serial.println("PWM Started.");
        } else if (input >= 0 && input <= 100) {
            // Set PWM duty cycle percentage and start output
            pwmCtrl.setPercent(input);
            pwmOut.write(pwmCtrl.getPwmValue());
            Serial.print("PWM set to ");
            Serial.print(input);
            Serial.println("%.");
        } else {
            // Invalid input detected, notify user
            Serial.print("Invalid input: ");
            Serial.println(inputStr);
        }
    }

    // Optional: periodically refresh PWM output if running
    if (pwmCtrl.running()) {
        pwmOut.write(pwmCtrl.getPwmValue());
    }
}
