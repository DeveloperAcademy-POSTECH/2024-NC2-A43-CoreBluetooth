import SwiftUI
import CoreBluetooth

struct BTPage: View {
    @ObservedObject var bluetoothManager = BluetoothManager()
    @State private var selectedDevice: CBPeripheral?
    @State private var navigateToPage: Bool = false
    @State private var deviceName: String = ""
    @State private var rssi: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("대상 선택하기")
                .font(.largeTitle)
                .bold()
                .padding(.horizontal)
            
            Toggle(isOn: $bluetoothManager.bluetoothEnabled) {
                Text("Bluetooth")
                    .font(.system(size: 24, weight: .semibold))
            }
            .onChange(of: bluetoothManager.bluetoothEnabled) { value in
                if value {
                    bluetoothManager.startScanning()
                } else {
                    bluetoothManager.stopScanning()
                }
            }
            .padding(.horizontal)
            
            Text("내 기기 이름: \(bluetoothManager.deviceName)")
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal)
            
            if bluetoothManager.bluetoothEnabled {
                List {
                    Section(header: Text("기존에 연결되었던 기기")) {
                        ForEach(bluetoothManager.connectedDevices, id: \.identifier) { device in
                            Button(action: {
                                selectedDevice = device
                                bluetoothManager.connectToDevice(device)
                                deviceName = device.name ?? "Unknown Device"
                                rssi = device.rssiValue?.intValue ?? 0
                                navigateToPage = true
                                bluetoothManager.stopScanning()
                            }) {
                                HStack {
                                    Text(device.name ?? "Unknown Device")
                                        .foregroundColor(.black)
                                    if selectedDevice == device && bluetoothManager.isConnecting {
                                        Spacer()
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle())
                                    }
                                }
                            }
                        }
                    }
                    
                    Section(header: HStack {
                        Text("새로운 기기")
                        if bluetoothManager.isScanning {
                            Spacer().frame(width: 20)
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                    }) {
                        ForEach(bluetoothManager.discoveredDevices.prefix(30), id: \.identifier) { device in
                            Button(action: {
                                selectedDevice = device
                                bluetoothManager.connectToDevice(device)
                                deviceName = device.name ?? "Unknown Device"
                                rssi = device.rssiValue?.intValue ?? 0
                                navigateToPage = true
                                bluetoothManager.stopScanning()
                                print("try to connect \(device.name ?? "Unknown Device")")
                            }) {
                                HStack {
                                    Text(device.name ?? "Unknown Device")
                                        .foregroundColor(.black)
                                    if selectedDevice == device && bluetoothManager.isConnecting {
                                        Spacer()
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle())
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
            } else {
                Spacer()
            }
        }
        .background(
            NavigationLink(destination: FirstPage(bluetoothManager: bluetoothManager, deviceName: deviceName, rssi: rssi), isActive: $navigateToPage) {
                EmptyView()
            }
        )
            }
        }
    

struct BTPage_Previews: PreviewProvider {
    static var previews: some View {
        BTPage()
    }
}
