#include <ArduinoBLE.h>
#include <Arduino_BMI270_BMM150.h>

// =============================================
// Variable Initialization
// =============================================
// BLE Attributes
BLEService sensorService("19B10000-E8F2-537E-4F6C-D104768A1214");  
BLEStringCharacteristic sensorDataJSON("19B10001-E8F2-537E-4F6C-D104768A1214", BLERead | BLENotify, 128);

// Timing control variables
unsigned long previousMillis = 0;
const long interval = 200; // 200ms interval for 5Hz frequency

// Variables to store sensor readings
float ax = 0, ay = 0, az = 0, mx = 0, my = 0, mz = 0;

// =============================================
// Initial Setup
// =============================================
void setup() {
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
}

// =============================================
// Main Loop
// =============================================
void loop() {
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
}