import SwiftUI

struct FourthPage: View {
    @ObservedObject var bluetoothManager: BluetoothManager
    var deviceName: String
    @State private var rssi: Int?
    @State private var connectDevice: String
    @State private var connectStrength: Int
    @State private var num: Int = 3
    let status = ["안전", "주의", "위험", "긴급"]
    let statusComment = ["피보호자가 옆에 있습니다.", "피보호자가 근처에 있습니다.", "피보호자와 멀어졌습니다.", "피보호자와 연결이 해제되었습니다."]

    init(bluetoothManager: BluetoothManager, deviceName: String, rssi: Int?) {
        self.bluetoothManager = bluetoothManager
        self.deviceName = deviceName
        _rssi = State(initialValue: rssi)
        _connectDevice = State(initialValue: deviceName)
        _connectStrength = State(initialValue: (rssi ?? -100) + 100)
    }

    var body: some View {
        ZStack {
            // 배경 그라데이션
            RadialGradient(gradient: Gradient(colors: [Color.gray.opacity(0.6), Color.red.opacity(0.8)]), center: .center, startRadius: 140, endRadius: 170)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                //  여백 맞추기 용도
                VStack {
                    Text("\n")
                }
                
                Spacer()
                
                VStack {
                    Text(status[num])
                        .font(.system(size: 80))
                        .fontWeight(.bold)
                        .padding(.bottom, 1.0)
                    
                    Text(statusComment[num])
                        .font(.system(size: 25))
                }
                .foregroundColor(.red)
                
                Spacer()
                
                VStack {
                    Text("\(connectDevice)과 연결되어 있습니다.")
                        .font(.system(size: 20))
                        .padding(.bottom, 1.0)
                    
                    Text("신호강도 : \(connectStrength)")
                        .font(.system(size: 25))
                        .fontWeight(.bold)
                }
            }
            .padding(20)
        }
        .background(Color("DangerousColor"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let connectedDevice = bluetoothManager.connectedDevices.first(where: { $0.name == deviceName }) {
                rssi = connectedDevice.rssiValue?.intValue ?? rssi
                connectStrength = (connectedDevice.rssiValue?.intValue ?? -100) + 100
                bluetoothManager.updateConnectedDeviceInfo(connectedDevice)
            }
        }
        .onChange(of: bluetoothManager.connectedDevice) { _ in
            if let connectedDevice = bluetoothManager.connectedDevices.first(where: { $0.name == deviceName }) {
                rssi = connectedDevice.rssiValue?.intValue ?? rssi
                connectStrength = (connectedDevice.rssiValue?.intValue ?? -100) + 100
            }
        }
    }
}

struct FourthPage_Previews: PreviewProvider {
    static var previews: some View {
        FourthPage(bluetoothManager: BluetoothManager(), deviceName: "Sample Device", rssi: nil)
    }
}
