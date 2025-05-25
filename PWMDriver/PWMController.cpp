#include "PWMController.h"

/**
 * @brief Starts PWM output.
 * 
 * Sets the internal running flag to true, indicating that the PWM output
 * should be considered active. The actual hardware output should be updated
 * separately by the caller.
 */
void PWMController::start() {
    isRunning = true;
}

/**
 * @brief Stops PWM output and resets PWM duty cycle.
 * 
 * Clears the running flag and resets the PWM duty cycle to zero.
 * This ensures that when stopped, no output signal will be generated.
 */
void PWMController::stop() {
    isRunning = false;
    pwmValue = 0;
}

/**
 * @brief Sets the PWM duty cycle percentage and starts PWM.
 * 
 * Accepts an input percentage, clamps it within the valid range (0-100),
 * converts it to a PWM value scaled between 0 and 255, and stores it.
 * Automatically marks PWM as running so that output should be enabled.
 * 
 * @param percent Duty cycle percentage to set (0-100).
 */
void PWMController::setPercent(int percent) {
    // Clamp input to valid range
    if (percent < 0) percent = 0;
    if (percent > 100) percent = 100;

    // Convert percentage (0-100) to PWM value (0-255)
    pwmValue = (percent * 255) / 100;

    // Mark PWM as running
    isRunning = true;
}

/**
 * @brief Gets the current PWM output value.
 * 
 * Returns the PWM duty cycle value only if PWM is running;
 * otherwise, returns zero to indicate no output.
 * 
 * @return int PWM value between 0 and 255.
 */
int PWMController::getPwmValue() const {
    return isRunning ? pwmValue : 0;
}

/**
 * @brief Checks if PWM is currently active.
 * 
 * @return true if PWM is running, false otherwise.
 */
bool PWMController::running() const {
    return isRunning;
}
