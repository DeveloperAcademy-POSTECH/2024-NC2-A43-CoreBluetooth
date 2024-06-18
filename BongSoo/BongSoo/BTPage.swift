import SwiftUI
import CoreBluetooth

struct BTPage: View {
    @ObservedObject var bluetoothManager = BluetoothManager()
    @State private var selectedDevice: CBPeripheral?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
                Text("대상 선택하기")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 16)
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
                                NavigationLink(destination: FirstPage(deviceName: device.name ?? "Unknown Device", rssi: device.rssi ?? 0).onAppear {
                                    selectedDevice = device
                                    bluetoothManager.connectToDevice(device)
                                }) {
                                    Text(device.name ?? "Unknown Device")
                                        .foregroundColor(.black)
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
                            ForEach(bluetoothManager.discoveredDevices, id: \.identifier) { device in
                                NavigationLink(destination: FirstPage(deviceName: device.name ?? "Unknown Device", rssi: device.rssi ?? 0).onAppear {
                                    selectedDevice = device
                                    bluetoothManager.connectToDevice(device)
                                }) {
                                    Text(device.name ?? "Unknown Device")
                                        .foregroundColor(.black)
                                }
                            }
                        }
                    }
                    .listStyle(GroupedListStyle())
                } else {
                    Spacer()
                }

                Spacer() // 아래에 공간 추가
            }
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear {
                bluetoothManager.stopScanning()
            }
        }
}

struct BTPage_Previews: PreviewProvider {
    static var previews: some View {
        BTPage()
    }
}
