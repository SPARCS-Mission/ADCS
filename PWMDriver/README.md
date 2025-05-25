# MTQ Driver: Modular PWM Controller for CubeSat Magnetorquers

This repository contains a modular, platform-independent driver for controlling **magnetorquer (MTQ)** in CubeSats using PWM. The driver is written in standard C++ and is designed for portability across embedded platforms, including STM32, Arduino, and other microcontrollers.

A test interface for **Arduino Mega 2560** is included to validate functionality using serial commands and an LED (or MTQ prototype) connected to a PWM-capable pin.


## Purpose

Magnetorquers require precise control of PWM duty cycles to generate torque for attitude control. This driver separates **PWM logic** from **hardware-specific control**, making it reusable, testable, and portable.

The driver can be integrated into real CubeSat ADCS systems or used as a standalone controller for laboratory testing and development.


## File Structure and Descriptions

### `PWMController.h`
> **Core driver class – Platform-independent**

- Provides a simple C++ class for controlling PWM as a percentage (0–100%).
- Handles internal state (`start`, `stop`) and maps percentage to a hardware-compatible 8-bit value (0–255).
- Designed to be embedded into higher-level systems or abstracted via hardware adapters.


### `PWMController.cpp`
> **Implementation of the core driver**

- Contains method definitions for:
  - `start()`, `stop()`
  - `setPercent(int percent)`
  - `getPwmValue() const`
  - `running() const`


### `ArduinoPWMAdapter.h`
> **Hardware adapter for Arduino-based testing**

- Simple class to wrap Arduino’s `analogWrite()` functionality.
- Allows the core driver (`PWMController`) to remain hardware-agnostic.
- Can be replaced with STM32 HAL or other low-level drivers in production builds.


### `PWMTest.ino`
> **Interactive Arduino test sketch**

- Connects the driver to an Arduino PWM pin (e.g., pin 7).
- Accepts serial commands via USB to simulate operation of a magnetorquer.
- Maps user input (e.g., "50") to PWM duty cycle and applies it to the output pin.


## Test Instructions (for Arduino)

1. **Hardware setup:**
   - Connect an LED (or magnetorquer coil) and current-limiting resistor to **digital pin 7** of an Arduino Mega 2560.
   - Ground the other side of the load.

2. **Upload sketch:**
   - Open `PWMTest.ino` in the Arduino IDE.
   - Upload to your Arduino board.

3. **Open Serial Monitor:**
   - Set baud rate to **9600**.
   - Set line ending to **Newline**.

4. **Command input:**

| Command | Description            |
|---------|------------------------|
| `1111`  | Start PWM              |
| `1110`  | Stop PWM               |
| `0–100` | Set duty cycle in %    |

5. **Example session:**
   - Enter `50` → Output set to 50% PWM
   - Enter `1111` → Start signal applied
   - Enter `1110` → Output stopped


## Porting to STM32 (or other platforms)

This driver is platform-agnostic. To use with STM32:

- **Replace `ArduinoPWMAdapter`** with a new adapter that calls `HAL_TIM_PWM_Start()` or equivalent.
- Use your existing hardware abstraction layer (HAL/LL) to implement the `write(int pwmValue)` method.
- Keep `PWMController` and its usage unchanged.
- Integrate into RTOS tasks or main loop as appropriate.

---

