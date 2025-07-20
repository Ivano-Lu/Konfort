# Konfort
<div align='center'> <img src = "img_solar_cell.jpg" alt = "Device-Image/Logo" width = "500"> </div>



## Table of contents
- [About The Project](#about-the-project)
- [Functionality](#functionality)
- [Requirements](#requirements)
- [Project Layout](#project-layout)
    - [Folder Structure](#folder-structure)
- [Get Started](#get-started)
- [Video and Presentation](#video-and-presentation)
- [Team Members](#team-members)



## About The Project
Konfort is a device designed to monitor and improve posture through real-time data collection and analysis. 
This innovative wearable technology aims to help users maintain a healthy posture, thereby preventing potential musculoskeletal issues and enhancing overall well-being.

Konfort employs advanced sensors to track posture-related metrics, offering users insights and recommendations to encourage better alignment throughout their daily activities.

Here you can find general information. For more information about each component, see the corresponding README file in each subdirectory.


## Functionality
The primary functionality of Konfort revolves around its ability to gather posture data using an integrated gyroscope and accelerometer. These sensors work together to detect angular displacement and orientation. Here's how it works:

- Data collection: The accelerometer and the magnetometer continuously collect data about the user's spinal alignment, measuring angles using 3 axis inertial measurement unit (IMU).

- Data processing: The raw data collected by the sensors is processed by a microcontroller (nRF52840) embedded within the device. 
The firmware translates this data into a user-friendly format, converting the readings into a JSON structure for transmission.

- Wireless Communication: Using Bluetooth Low Energy (BLE), Konfort wirelessly transmits the processed posture data to a mobile application. This enables seamless realt-time monitoring and interaction.

- Mobile Application: The mobile app, developed in SwiftUI, provides a user-friendly interface where individuals can visualize their posture data live. 
Additionally, it offers in-depth analytics by calling an external API, which processes the data for complex analysis, such as posture trends over time.



## Requirements
### Hardware
To use this project, you will need the following hardware:

- [Arduino Nano 33 BLE Rev2](https://docs.arduino.cc/hardware/nano-33-ble-rev2/)
    - internal acceletometer
    - internal magnetometer
    - internal 2.4 GHz Bluetooth® 5 Low Energy module
- Materials for wearable device:
    - 2x Neodymium block magnets 30x10x5mm
    - non-woven fabric 100x50cm
    - Elastic 40mm wide


### Software
To use this project, you will need the following software:

- [Arduino IDE](https://www.arduino.cc/en/software/)
    - ArduinoBLE library. Install it to use the integrated Ble module
    - Arduino_BMI270_BMM150 library. Install it
- [Xcode](http://developer.apple.com/xcode/)



## Project Layout
The architecture of Konfort is organized into 4 main components/levels:

- **Hardware Layer**: This includes the physical device, which houses the Arduino microcontroller for data processing, with its integrated sensors (accelerometer, magnetometer) and BLE module for wireless communication. 
The device is designed to be worn comfortably along the spine, promoting usage throughout daily activities.

- **Firmware Layer**: The firmware developed for Konfort is responsible for data collection, processing, and communication. 
It converts raw sensor data into a readable format (JSON) and sends it to the mobile app via BLE. This layer ensures efficient operation and minimizes latency in data transmission.

- **Software Layer**: The mobile applciation serves as user interface for Konfort. It displays real-time posture metrics, and retrieves insights from a backend server.

- **Backend Layer**: built with SpringBoot, processes incoming data, stores it in a database, handles users' profiles and provides advanced analytics and recommendations via an API. 
This server-side component ensures that the data remain secure and accessible for future anylsis.


### Folder Structure
```
├── README.md
└── LICENCE.txt
└── App
└── Backend
└── Firmware
```



## Get Started
In order to build and upload the project yourself, first clone the 'main' branch of the repo
```
git clone https://github.com/Ivano-Lu/Konfort
```
or you can download the zipped forlder and unzip it in you working directory.

Then, to configure and run each component, follow the instructions contained in the README file of each subdirectory.



## Video and Presentation
[See Konfort in Action](https://www.youtube.com/watch?v=uDXNCm9Ask0)

[Presentation](https://docs.google.com/presentation/d/13WsYzTqbhEDQ-sw2M0TznusOs9hSoLJpFXpJRooucAw/edit?slide=id.g3709d9b3e58_0_46#slide=id.g3709d9b3e58_0_46)



## Team Members
|Name|Email|
|--|--|
|Matteo Zendri|matteo.zendri-1@studenti.unitn.it|
|Ivano Lu|ivano.lu@studenti.unitn.it|

- Matteo Zendri (Leader)
    - Contributed mainly to the initial research to design of the device and develop the posture assessment algorithms, 
    the creation of the physical device and the implementation of the firmware.
- Ivano Lu
    - Contributed mainly to the mobile app developement, the creation of the backend and the authentication system 
    and the implementation and adption of the posture assessment algorithms.
