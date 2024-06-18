import SwiftUI

struct FourthPage: View {
    @ObservedObject var bluetoothManager: BluetoothManager
    var deviceName: String
    @State private var rssi: Int?

    init(bluetoothManager: BluetoothManager, deviceName: String, rssi: Int?) {
        self.bluetoothManager = bluetoothManager
        self.deviceName = deviceName
        _rssi = State(initialValue: rssi)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Device Name: \(deviceName)")
                .font(.largeTitle)
                .bold()
                .padding(.top, 16)
                .padding(.horizontal)

            if let rssi = rssi {
                Text("RSSI: \(rssi)")
                    .font(.system(size: 24, weight: .semibold))
                    .padding(.horizontal)
            } else {
                Text("Disconnected")
                    .font(.system(size: 24, weight: .semibold))
                    .padding(.horizontal)
            }

            Spacer()
        }
        .background(Color("DangerousColor"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            updateNavigation(rssi: rssi)
            if let connectedDevice = bluetoothManager.connectedDevice {
                rssi = connectedDevice.rssiValue?.intValue
            } else {
                rssi = nil
            }
        }
        .onChange(of: bluetoothManager.connectedDevice?.rssiValue) { newValue in
            rssi = newValue?.intValue
            updateNavigation(rssi: rssi)
        }
    }

    private func updateNavigation(rssi: Int?) {
        if let rssi = rssi {
            navigateToAppropriatePage(rssi: rssi)
        } else {
            navigateToAppropriatePage(rssi: nil)
        }
    }

    private func navigateToAppropriatePage(rssi: Int?) {
        if let rssi = rssi {
            if rssi >= -65 {
                UIApplication.shared.windows.first?.rootViewController = UIHostingController(rootView: FirstPage(bluetoothManager: bluetoothManager, deviceName: deviceName, rssi: rssi))
            } else if rssi >= -85 {
                UIApplication.shared.windows.first?.rootViewController = UIHostingController(rootView: SecondPage(bluetoothManager: bluetoothManager, deviceName: deviceName, rssi: rssi))
            } else {
                UIApplication.shared.windows.first?.rootViewController = UIHostingController(rootView: ThirdPage(bluetoothManager: bluetoothManager, deviceName: deviceName, rssi: rssi))
            }
        } else {
            // Remain on FourthPage
        }
    }
}

struct FourthPage_Previews: PreviewProvider {
    static var previews: some View {
        FourthPage(bluetoothManager: BluetoothManager(), deviceName: "Sample Device", rssi: nil)
    }
}
