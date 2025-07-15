//
//  BluetoothManager.swift
//  Konfort
//
//  Created by Ivano Lu on 15/07/25.
//

import Foundation
import CoreBluetooth

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    var targetPeripheral: CBPeripheral?
    var rxCharacteristic: CBCharacteristic?

    @Published var receivedText = ""

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanning()
        }
    }

    private func startScanning() {
        guard centralManager.isScanning == false else { return }
        print("🔍 Inizio scansione per 'Konfort'...")
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }

    private func stopScanning() {
        if centralManager.isScanning {
            centralManager.stopScan()
            print("⏹️ Scansione fermata")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let name = peripheral.name ?? "🕵️‍♂️ Nessun nome"
            print("🔍 Trovato dispositivo: \(name)")
        
        if peripheral.name?.contains("Arduino") == true {
            print("✅ Trovato dispositivo Konfort")
            targetPeripheral = peripheral
            stopScanning()
            centralManager.connect(peripheral, options: nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("🔗 Connesso a \(peripheral.name ?? "sconosciuto")")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("⚠️ Connessione fallita. Riprovo...")
        targetPeripheral = nil
        startScanning()
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("❌ Disconnesso da \(peripheral.name ?? "sconosciuto"). Riprovo la scansione...")
        targetPeripheral = nil
        startScanning()
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        peripheral.services?.forEach { service in
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        service.characteristics?.forEach { characteristic in
            if characteristic.properties.contains(.read) || characteristic.properties.contains(.notify) {
                rxCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value,
           let string = String(data: data, encoding: .utf8) {
            DispatchQueue.main.async {
                self.receivedText += string
            }
        }
    }
}


