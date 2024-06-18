import Foundation
import CoreBluetooth
import UIKit

extension CBPeripheral {
    private struct AssociatedKeys {
        static var rssiKey = "rssiKey"
    }

    var rssiValue: NSNumber? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.rssiKey) as? NSNumber
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.rssiKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    @Published var discoveredDevices: [CBPeripheral] = []
    @Published var connectedDevices: [CBPeripheral] = []
    @Published var bluetoothEnabled = false
    @Published var isScanning = false
    @Published var deviceName: String = UIDevice.current.name
    @Published var connectedDevice: CBPeripheral? {
        didSet {
            if let connectedDevice = connectedDevice, let index = discoveredDevices.firstIndex(where: { $0.identifier == connectedDevice.identifier }) {
                discoveredDevices.remove(at: index)
            }
            startReadingRSSI()
        }
    }
    @Published var isConnecting = false
    @Published var rssiValue: Int? // RSSI 값을 나타내는 변수 추가

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        loadConnectedDevices()
    }
    
    func startScanning() {
        if centralManager.state == .poweredOn {
            discoveredDevices.removeAll()
            isScanning = true
            centralManager.scanForPeripherals(withServices: nil, options: nil)
            print("Scanning started")
        }
    }
    
    func stopScanning() {
        centralManager.stopScan()
        isScanning = false
        print("Scanning stopped")
    }
    
    func toggleBluetooth() {
        if centralManager.state == .poweredOn {
            stopScanning()
            centralManager = CBCentralManager(delegate: self, queue: nil)
            bluetoothEnabled = false
        } else if centralManager.state == .poweredOff {
            centralManager = CBCentralManager(delegate: self, queue: nil)
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            bluetoothEnabled = true
            startScanning()
        case .poweredOff:
            bluetoothEnabled = false
            stopScanning()
        default:
            bluetoothEnabled = false
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Discovered device: \(peripheral.name ?? "Unknown Device"), RSSI: \(RSSI)")
        if !discoveredDevices.contains(peripheral) {
            peripheral.rssiValue = RSSI
            discoveredDevices.append(peripheral)
            peripheral.delegate = self
        } else {
            if let index = discoveredDevices.firstIndex(where: { $0.identifier == peripheral.identifier }) {
                discoveredDevices[index].rssiValue = RSSI
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if !connectedDevices.contains(where: { $0.identifier == peripheral.identifier }) {
            connectedDevices.append(peripheral)
            connectedDevice = peripheral
            peripheral.delegate = self
            isConnecting = false
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let index = connectedDevices.firstIndex(where: { $0.identifier == peripheral.identifier }) {
            connectedDevices.remove(at: index)
            if connectedDevice == peripheral {
                connectedDevice = nil
                rssiValue = nil // 연결이 끊어지면 RSSI 값을 nil로 설정
            }
        }
    }
    
    func connectToDevice(_ peripheral: CBPeripheral) {
        isConnecting = true
        centralManager.connect(peripheral, options: nil)
    }

    private func loadConnectedDevices() {
        // 연결된 기기 목록을 로드하는 역할을 합니다.
    }
    
    private func startReadingRSSI() {
        guard let device = connectedDevice else { return }
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.connectedDevice == nil {
                timer.invalidate()
            } else {
                device.readRSSI()
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        if peripheral == connectedDevice {
            peripheral.rssiValue = RSSI
            DispatchQueue.main.async {
                self.rssiValue = RSSI.intValue
                self.objectWillChange.send()
            }
        }
    }
}

