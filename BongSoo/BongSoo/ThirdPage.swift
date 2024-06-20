import SwiftUI

struct ThirdPage: View {
    @ObservedObject var bluetoothManager: BluetoothManager
    var deviceName: String
    @State private var rssi: Int

    init(bluetoothManager: BluetoothManager, deviceName: String, rssi: Int) {
        self.bluetoothManager = bluetoothManager
        self.deviceName = deviceName
        _rssi = State(initialValue: rssi)
    }

    var body: some View {
        ZStack {
            RadialGradient(gradient: Gradient(colors: [Color.gray.opacity(0.6), Color.orange.opacity(0.8)]), center: .center, startRadius: 140, endRadius: 170)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                VStack {
                    Text("위험")
                        .font(.system(size: 80))
                        .fontWeight(.bold)
                    
                    Text("피보호자와 멀어졌습니다.")
                        .font(.system(size: 25))
                }
                .foregroundColor(.orange)
                
                Spacer()
                
                VStack {
                    Text("\(deviceName)과 연결되어 있습니다.")
                        .font(.system(size: 20))
                    
                    Text("신호강도 : \(rssi + 100)")
                        .font(.system(size: 25))
                        .fontWeight(.bold)
                }
                .padding(.bottom)
            }
            .padding(20)
        }
        .background(Color("WarningColor"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            updateNavigation(rssi: rssi)
            if let connectedDevice = bluetoothManager.connectedDevice {
                rssi = connectedDevice.rssiValue?.intValue ?? rssi
            }
        }
        .onChange(of: bluetoothManager.connectedDevice?.rssiValue) { newValue in
            rssi = newValue?.intValue ?? rssi
            updateNavigation(rssi: rssi)
        }
    }

    private func updateNavigation(rssi: Int?) {
        if let rssi = rssi {
            if rssi >= -65 {
                UIApplication.shared.windows.first?.rootViewController = UIHostingController(rootView: SecondPage(bluetoothManager: bluetoothManager, deviceName: deviceName, rssi: rssi))
            } 
//            else if rssi < -100 {
//                UIApplication.shared.windows.first?.rootViewController = UIHostingController(rootView: FourthPage(bluetoothManager: bluetoothManager, deviceName: deviceName, rssi: rssi))
//            } 
            else {
                navigateToDisconnectionPage()
            }
        }
    }

    private func navigateToDisconnectionPage() {
        UIApplication.shared.windows.first?.rootViewController = UIHostingController(rootView: FourthPage(bluetoothManager: bluetoothManager, deviceName: deviceName, rssi: nil))
    }
}
