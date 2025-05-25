#ifndef PWM_CONTROLLER_H
#define PWM_CONTROLLER_H

/**
 * @class PWMController
 * @brief Manages the logic for PWM signal control independent of hardware.
 *
 * This class encapsulates the PWM state and duty cycle, providing
 * an interface to start, stop, and set PWM duty cycle as a percentage.
 * It maintains internal state to track if PWM is active and the current value.
 * 
 * @note This class does NOT interact directly with hardware; it only
 *       manages logical PWM values (0-255).
 */
class PWMController {
private:
    /**
     * @brief Flag indicating if PWM output is currently active.
     * 
     * True when PWM is started; false when stopped.
     */
    bool isRunning = false;

    /**
     * @brief PWM duty cycle value (0-255).
     * 
     * Represents the output intensity or duty cycle, mapped from
     * percentage input. Valid range is 0 (off) to 255 (full on).
     */
    int pwmValue = 0;

public:
    /**
     * @brief Starts PWM output using the current stored duty cycle.
     * 
     * Sets the internal running flag to true, enabling PWM output.
     * The actual hardware output must be updated separately.
     */
    void start();

    /**
     * @brief Stops PWM output and resets duty cycle to zero.
     * 
     * Clears the running flag and sets the internal PWM value to 0,
     * indicating the output should be turned off.
     */
    void stop();

    /**
     * @brief Sets the PWM duty cycle as a percentage and starts PWM.
     * 
     * Converts a given percentage (0-100) to a PWM value (0-255),
     * clamps invalid input to this range, updates the internal value,
     * and marks PWM as running.
     *
     * @param percent PWM duty cycle in percentage (0-100).
     */
    void setPercent(int percent);

    /**
     * @brief Retrieves the current PWM value (0-255).
     * 
     * Returns the duty cycle value only if PWM is running; otherwise,
     * returns 0 to indicate no output.
     *
     * @return int PWM duty cycle value between 0 and 255.
     */
    int getPwmValue() const;

    /**
     * @brief Checks if PWM output is currently active.
     *
     * @return true if PWM is running, false otherwise.
     */
    bool running() const;
};

#endif
