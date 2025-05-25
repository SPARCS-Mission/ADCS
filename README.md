# SPARCS Mission ADCS Repository

This repository contains the software modules developed for the **Attitude Determination and Control System (ADCS)** of SPARCS mission CubeSats. The ADCS is responsible for determining the satellite's orientation in space and controlling its attitude using actuators such as magnetorquers.

## Current Modules

### [PWM Controller (Magnetorquer Driver)](https://github.com/SPARCS-Mission/ADCS/tree/main/MTQDriver)

The **PWM Controller** module provides a hardware-agnostic driver to control magnetorquers via pulse-width modulation (PWM). This is critical for generating magnetic dipole moments to control CubeSat attitude using Earth’s magnetic field.

**Key Features:**

- Platform-independent PWM control logic (`PWMController`)
- Arduino-compatible hardware adapter for testing (`ArduinoPWMAdapter`)
- Test sketch with serial interface (`PWMTest.ino`)
- Scalable architecture for porting to STM32 and other embedded platforms

> 💡 This module is tested on Arduino Mega 2560 with MTQ coil on pin 7.

## Contact
Maintained by [Danial Rezaei](https://github.com/DanialRezaei)  
For questions, feedback, or collaboration, feel free to reach out through GitHub Issues or contact directly via GitHub.
