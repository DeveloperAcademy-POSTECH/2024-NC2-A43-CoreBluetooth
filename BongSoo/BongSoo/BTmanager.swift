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
    @Published var connectedDevice: CBPeripheral?
    @Published var connectStrength: Int = 0
    @Published var isConnecting = false
    private var scanTimer: Timer?
    private var rssiTimer: Timer?
    private var tempDiscoveredDevices: [CBPeripheral] = []

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        loadConnectedDevices()
    }
    
    func startScanning() {
        if centralManager.state == .poweredOn {
            tempDiscoveredDevices.removeAll()
            isScanning = true
            centralManager.scanForPeripherals(withServices: nil, options: nil)
            print("Scanning started")
            scanTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                self.updateDiscoveredDevices()
                self.restartScanning()
            }
        }
    }
    
    func stopScanning() {
        centralManager.stopScan()
        isScanning = false
        scanTimer?.invalidate()
        scanTimer = nil
        print("Scanning stopped")
    }
    
    func restartScanning() {
        if isScanning {
            stopScanning()
            startScanning()
        }
    }
    
    func updateDiscoveredDevices() {
        print("Updating discovered devices")
        discoveredDevices = Array(tempDiscoveredDevices.prefix(30))
        tempDiscoveredDevices.removeAll()
        print("Discovered Devices: \(discoveredDevices.map { $0.name ?? "Unknown Device" })")
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
        if !tempDiscoveredDevices.contains(peripheral) {
            peripheral.rssiValue = RSSI
            tempDiscoveredDevices.append(peripheral)
            peripheral.delegate = self
        } else {
            if let index = tempDiscoveredDevices.firstIndex(where: { $0.identifier == peripheral.identifier }) {
                tempDiscoveredDevices[index].rssiValue = RSSI
            }
        }
        tempDiscoveredDevices.sort { ($0.rssiValue?.intValue ?? Int.min) > ($1.rssiValue?.intValue ?? Int.min) }
        if tempDiscoveredDevices.count > 30 {
            tempDiscoveredDevices = Array(tempDiscoveredDevices.prefix(30))
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if !connectedDevices.contains(where: { $0.identifier == peripheral.identifier }) {
            connectedDevices.append(peripheral)
            peripheral.delegate = self
            updateConnectedDeviceInfo(peripheral)
            isConnecting = false
            startReadingRSSI()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let index = connectedDevices.firstIndex(where: { $0.identifier == peripheral.identifier }) {
            connectedDevices.remove(at: index)
            if connectedDevice?.name == peripheral.name {
                connectedDevice = nil
                connectStrength = 0
            }
        }
        stopReadingRSSI()
    }
    
    func connectToDevice(_ peripheral: CBPeripheral) {
        isConnecting = true
        centralManager.connect(peripheral, options: nil)
    }

    private func loadConnectedDevices() {
        // 이 함수는 연결된 기기 목록을 로드하는 역할을 합니다.
        // 연결된 기기 정보를 저장하고 불러오는 로직을 여기에 구현합니다.
        // 예를 들어, UserDefaults나 데이터베이스를 사용할 수 있습니다.
        // 이 예제에서는 샘플 데이터를 사용합니다.
    }

    func updateConnectedDeviceInfo(_ peripheral: CBPeripheral) {
        connectedDevice = peripheral
        connectStrength = (peripheral.rssiValue?.intValue ?? -100) + 100
    }
    
    private func startReadingRSSI() {
        rssiTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if let connectedDevice = self.connectedDevice {
                connectedDevice.readRSSI()
            }
        }
    }
    
    private func stopReadingRSSI() {
        rssiTimer?.invalidate()
        rssiTimer = nil
    }

    // 필수 델리게이트 메서드 구현
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        // 이 메서드는 필수적으로 구현해야 합니다.
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
                // 특성 처리
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        if peripheral == connectedDevices.first(where: { $0.identifier == peripheral.identifier }) {
            peripheral.rssiValue = RSSI
            updateConnectedDeviceInfo(peripheral)
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
}
