import SwiftUI

struct FourthPage: View {
    @ObservedObject var bluetoothManager: BluetoothManager
    var deviceName: String
    @State private var rssi: Int?
    @State private var connectDevice: String
    @State private var connectStrength: Int
    @State private var disconnectTime: Date?
    @State private var elapsedTime: Int = 0
    @State private var timer: Timer?

    init(bluetoothManager: BluetoothManager, deviceName: String, rssi: Int?) {
        self.bluetoothManager = bluetoothManager
        self.deviceName = deviceName
        _rssi = State(initialValue: rssi)
        _connectDevice = State(initialValue: deviceName)
        _connectStrength = State(initialValue: (rssi ?? -100) + 100)
    }

    var body: some View {
        ZStack {
            RadialGradient(gradient: Gradient(colors: [Color.gray.opacity(0.6), Color.red.opacity(0.8)]), center: .center, startRadius: 140, endRadius: 170)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                VStack {
                    Text("긴급")
                        .font(.system(size: 80))
                        .fontWeight(.bold)
                        .padding(.bottom, 1.0)
                    
                    Text("피보호자와 연결이 해제되었습니다.")
                        .font(.system(size: 25))
                }
                .foregroundColor(.red)
                
                Spacer()
                
                VStack {
                    Text("\(connectDevice)과 연결 해제 되었습니다.")
                        .font(.system(size: 20))
                        .padding(.bottom, 1.0)
                    
                    Text("신호강도 : \(connectStrength)")
                        .font(.system(size: 25))
                        .fontWeight(.bold)
                    
                    if disconnectTime != nil {
                        Text("끊어진 시간: \(elapsedTime) 초 경과")
                            .font(.system(size: 18))
                            .padding(.top, 10)
                    }
                }
            }
            .padding(20)
        }
        .background(Color("DangerousColor"))
        .navigationBarTitleDisplayMode(.inline)
//        .onAppear {
//            updateConnectionState()
//        }
//        .onChange(of: bluetoothManager.connectedDevice) { _ in
//            updateConnectionState()
//        }
    }

//    private func updateConnectionState() {
//        if let connectedDevice = bluetoothManager.connectedDevices.first(where: { $0.name == deviceName }) {
//            rssi = connectedDevice.rssiValue?.intValue ?? rssi
//            connectStrength = (connectedDevice.rssiValue?.intValue ?? -100) + 100
//            disconnectTime = nil
//            elapsedTime = 0
//            stopTimer()
//        } else {
//            disconnectTime = Date()
//            startTimer()
//        }
//    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if let disconnectTime = disconnectTime {
                elapsedTime = Int(Date().timeIntervalSince(disconnectTime))
            }
        }
        RunLoop.current.add(timer!, forMode: .common)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
