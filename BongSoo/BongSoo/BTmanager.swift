import SwiftUI
import CoreBluetooth

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    @Published var discoveredDevices: [CBPeripheral] = []
    @Published var connectedDevices: [CBPeripheral] = []
    @Published var bluetoothEnabled = false
    @Published var isScanning = false
    @Published var deviceName: String = UIDevice.current.name

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
        }
    }
    
    func stopScanning() {
        centralManager.stopScan()
        isScanning = false
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
            startScanning() // Bluetooth가 켜지면 스캔 시작
        case .poweredOff:
            bluetoothEnabled = false
            stopScanning() // Bluetooth가 꺼지면 스캔 중지
        default:
            bluetoothEnabled = false
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !discoveredDevices.contains(peripheral) {
            discoveredDevices.append(peripheral)
            peripheral.delegate = self
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if !connectedDevices.contains(where: { $0.identifier == peripheral.identifier }) {
            connectedDevices.append(peripheral)
            peripheral.delegate = self
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let index = connectedDevices.firstIndex(where: { $0.identifier == peripheral.identifier }) {
            connectedDevices.remove(at: index)
        }
    }
    
    func connectToDevice(_ peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
    }

    private func loadConnectedDevices() {
        // 이 함수는 연결된 기기 목록을 로드하는 역할을 합니다.
        // 연결된 기기 정보를 저장하고 불러오는 로직을 여기에 구현합니다.
        // 예를 들어, UserDefaults나 데이터베이스를 사용할 수 있습니다.
        // 이 예제에서는 샘플 데이터를 사용합니다.
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
}
