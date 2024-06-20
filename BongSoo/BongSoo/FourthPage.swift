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
    @State private var showAlert: Bool = false
    @State private var showAlert2: Bool = false
    @State private var navigateToBTPage: Bool = false

    init(bluetoothManager: BluetoothManager, deviceName: String, rssi: Int?) {
        self.bluetoothManager = bluetoothManager
        self.deviceName = deviceName
        _rssi = State(initialValue: rssi)
        _connectDevice = State(initialValue: deviceName)
        _connectStrength = State(initialValue: (rssi ?? -100) + 100)
    }

    var body: some View {
        NavigationView {
            ZStack {
                RadialGradient(gradient: Gradient(colors: [Color.gray.opacity(0.6), Color.red.opacity(0.8)]), center: .center, startRadius: 140, endRadius: 170)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    
                    Text("연결 해제 후 시간 경과 : \(elapsedTime) 초")
                    
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
                    .padding(.bottom, 50)
                    
                    Spacer()
                    
                    VStack(spacing: 15) {
                        // '재연결 하기' 버튼
                        Button(action: {
                            print("재연결 버튼이 눌렸습니다!")
                            navigateToBTPage = true
                        }, label: {
                            Text("재연결 하기")
                                .frame(maxWidth: .infinity)
                        })
                        .buttonStyle(.borderedProminent)

                        NavigationLink(destination: BTPage(bluetoothManager: bluetoothManager), isActive: $navigateToBTPage) {
                            EmptyView()
                        }

                        // '전화하기' 버튼
                        Button(action: {
                            print("전화하기 버튼이 눌렸습니다!")
                            showAlert2 = true
                        }, label: {
                            Text("전화하기")
                                .frame(maxWidth: .infinity)
                        })
                        .buttonStyle(.borderedProminent)
                        .alert(isPresented: $showAlert2) {
                            Alert(
                                title: Text("주의"),
                                message: Text("정말 루시드를 호출하시겠습니까?"),
                                primaryButton: .destructive(Text("호출")) {
                                    print("사용자가 호출를 선택했습니다.")
                                    makePhoneCall()                                },
                                secondaryButton: .cancel(Text("취소")) {
                                    print("사용자가 취소를 선택했습니다.")
                                }
                            )
                        }
                        
                        // '112 신고하기' 버튼
                        Button(action: {
                            print("112 신고하기 버튼이 눌렸습니다!")
                            showAlert = true
                        }, label: {
                            Text("112 신고하기")
                                .frame(maxWidth: .infinity)
                        })
                        .buttonStyle(.borderedProminent)
                        .alert(isPresented: $showAlert) {
                            Alert(
                                title: Text("경고"),
                                message: Text("정말 112에 신고하시겠습니까?"),
                                primaryButton: .destructive(Text("신고")) {
                                    print("사용자가 신고를 선택했습니다.")
                                    policePhoneCall()
                                },
                                secondaryButton: .cancel(Text("취소")) {
                                    print("사용자가 취소를 선택했습니다.")
                                }
                            )
                        }
                    }
                }
                .padding(20)
            }
            .onAppear {
                updateConnectionState()
                if disconnectTime == nil {
                    disconnectTime = Date()
                }
                startTimer()
            }
            .onChange(of: bluetoothManager.connectedDevice) { _ in
                updateConnectionState()
            }
        }
    }

    private func updateConnectionState() {
        if let connectedDevice = bluetoothManager.connectedDevices.first(where: { $0.name == deviceName }) {
            rssi = connectedDevice.rssiValue?.intValue ?? rssi
            connectStrength = (connectedDevice.rssiValue?.intValue ?? -100) + 100
            disconnectTime = nil
            elapsedTime = 0
            stopTimer()
        } else {
            disconnectTime = Date()
            startTimer()
        }
    }

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

    // 전화걸기 함수
    func makePhoneCall() {
        let phoneNumber = "tel://010-4510-4927"
        if let url = URL(string: phoneNumber) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                print("전화 앱을 열 수 없습니다.")
            }
        }
    }
    
    // 112 전화걸기 함수
    func policePhoneCall() {
        let phoneNumber = "tel://112"
        if let url = URL(string: phoneNumber) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                print("전화 앱을 열 수 없습니다.")
            }
        }
    }
}

struct FourthPage_Previews: PreviewProvider {
    static var previews: some View {
        FourthPage(bluetoothManager: BluetoothManager(), deviceName: "Sample Device", rssi: nil)
    }
}
