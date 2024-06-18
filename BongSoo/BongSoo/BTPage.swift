import SwiftUI
import CoreBluetooth

struct BTPage: View {
    @ObservedObject var bluetoothManager = BluetoothManager()
    @State private var selectedDevice: CBPeripheral?
    @State private var navigateToPage: Int? = nil

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
                        ForEach(bluetoothManager.discoveredDevices, id: \.identifier) { device in
                            Button(action: {
                                selectedDevice = device
                                bluetoothManager.connectToDevice(device)
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

            // RSSI 값에 따라 페이지 이동
            NavigationLink(destination: FirstPage(bluetoothManager: bluetoothManager, deviceName: selectedDevice?.name ?? "Unknown Device", rssi: bluetoothManager.rssiValue ?? 0), tag: 1, selection: $navigateToPage) {
                EmptyView()
            }
            NavigationLink(destination: SecondPage(bluetoothManager: bluetoothManager, deviceName: selectedDevice?.name ?? "Unknown Device", rssi: bluetoothManager.rssiValue ?? 0), tag: 2, selection: $navigateToPage) {
                EmptyView()
            }
            NavigationLink(destination: ThirdPage(bluetoothManager: bluetoothManager, deviceName: selectedDevice?.name ?? "Unknown Device", rssi: bluetoothManager.rssiValue ?? 0), tag: 3, selection: $navigateToPage) {
                EmptyView()
            }
            NavigationLink(destination: FourthPage(bluetoothManager: bluetoothManager, deviceName: selectedDevice?.name ?? "Unknown Device", rssi: nil), tag: 4, selection: $navigateToPage) {
                EmptyView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            bluetoothManager.stopScanning()
        }
        .onChange(of: bluetoothManager.rssiValue) { rssi in
            // RSSI 값이 변경될 때 페이지를 이동하도록 설정
            updateNavigation(rssi: rssi)
        }
    }

    private func updateNavigation(rssi: Int?) {
        if let rssi = rssi {
            if rssi >= -65 {
                navigateToPage = 1
            } else if rssi >= -85 {
                navigateToPage = 2
            } else {
                navigateToPage = 3
            }
        } else {
            navigateToPage = 4
        }
    }
}

struct BTPage_Previews: PreviewProvider {
    static var previews: some View {
        BTPage()
    }
}
