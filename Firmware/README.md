# Firmware Documentation

The firmware is the core of the posture monitoring device, responsible for acquiring data from sensors, processing it and sending it to the mobile app for real-time display and analysis. 
The device is designed to capture the user's posture by monitoring angular movements along the spine and sending notifications when improper posture is detected. 
The data is processed in the microcontroller (nRF52840) and transmitted via Bluetooth Low Energy (BLE) to the mobile application.



## Table of contents
- [Get Started](#get-started)
    - [Libraries Installation](#libraries-installation)
    - [Running Instructions](#running-instructions)
- [Working Flow](#working-flow)
    - [Initialization](#initialization)
    - [Setup](#setup)
    - [Main Loop](#main-loop)



## Get Started
### Libraries Installation
After downloading the Arduino IDE, you need to install the two libraries ArduinoBLE and Ardino_uBMI270_BMM150 to be able to use the BLE and the sensors.

Go to "Library Manager" (third icon on the left if you have Arduino IDE 2.3.7), find the two libraries, and install the latest version.
The code is tested with ArduinoBLE 1.4.0 and Ardino_uBMI270_BMM150 1.2.1.


### Running Instructions
Connect the Arduino board to the computer via micro USB cable.

Open Konfort.ino using Arduino IDE and select the correct board and port from those available.

Finally, press the upload button to upload the code to the board (the code will be automatically compiled if it wasn't already).



## Working Flow
### Initialization
The first step is to import the needed libraries
```ino
#include <ArduinoBLE.h>
#include <Arduino_BMI270_BMM150.h>
```

and then initialize the BLE attributes and variables to handle sending data at 5Hz and reading data from sensors.
```ino
// Attributi BLE
BLEService sensorService("19B10000-E8F2-537E-4F6C-D104768A1214");  
BLEStringCharacteristic sensorDataJSON("19B10001-E8F2-537E-4F6C-D104768A1214", BLERead | BLENotify, 128); // Buffer più grande per il JSON

// Variabili per il controllo del timing
unsigned long previousMillis = 0;
const long interval = 200; // Intervallo di 200ms per 5Hz

// Variabili per memorizzare le letture
float ax = 0, ay = 0, az = 0, mx = 0, my = 0, mz = 0;
```

### Setup
In the setup function, we initialize serial comunication, IMU (to enable accelerometer and magnetometer) and BLE. 

We also enable a LED, which we will use to visually notify the successful BLE connection to the user. When the LED is on, it indicates that a device is connected via BLE.

```ino
// Serial communication initialization
Serial.begin(9600);
while (!Serial);

// Built-in LED initialization
pinMode(LED_BUILTIN, OUTPUT);
digitalWrite(LED_BUILTIN, LOW);

// IMU initialization 
if (!IMU.begin()) {
    Serial.println("Error initializing IMU");
    while (1);
}

// BLE initialization 
if (!BLE.begin()) {
    Serial.println("Error initializing BLE");
    while (1);
}

// BLE Configuration
BLE.setLocalName("Konfort");
BLE.setAdvertisedService(sensorService);
sensorService.addCharacteristic(sensorDataJSON);
BLE.addService(sensorService);
BLE.advertise();

Serial.println("BLE ready");
```

### Main Loop
In the main loop, once the BLE connection is successful and the LED is turned on, the device continuously sends data at a frequency of 5Hz as a JSON message.

When the device is disconnected, the LED turns off and it waits for a new connection.

```ino
// Check if a device has connected
BLEDevice central = BLE.central();

if (central) {
    // Print connection details for debugging
    Serial.print("Connected to: ");
    Serial.println(central.address());

    // Turn LED on (BLE connected)
    digitalWrite(LED_BUILTIN, HIGH);

    while (central.connected()) {
        // Read sensors if available (overwrite previous values)
        if (IMU.accelerationAvailable()) IMU.readAcceleration(ax, ay, az);
        if (IMU.magneticFieldAvailable()) IMU.readMagneticField(mx, my, mz);

        // Timing control for sending data
        unsigned long currentMillis = millis();
        if (currentMillis - previousMillis >= interval) {
            previousMillis = currentMillis;

            // Create and send JSON
            char jsonBuffer[128];
            snprintf(
                jsonBuffer, sizeof(jsonBuffer),
                "{\"acc\":{\"x\":%.2f,\"y\":%.2f,\"z\":%.2f},\"mag\":{\"x\":%.2f,\"y\":%.2f,\"z\":%.2f}}",
                ax, ay, az, mx, my, mz
            );

            sensorDataJSON.writeValue(jsonBuffer);
            Serial.println(jsonBuffer);
        }
    }

    // Turn LED off (BLE disconnected)
    digitalWrite(LED_BUILTIN, LOW);
    Serial.print("Disconnected from: ");
    Serial.println(central.address());
}
```