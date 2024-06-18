import SwiftUI

struct FirstPage: View, Hashable {
    let deviceName: String
    let rssi: NSNumber

    static func == (lhs: FirstPage, rhs: FirstPage) -> Bool {
        return lhs.deviceName == rhs.deviceName && lhs.rssi == rhs.rssi
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(deviceName)
        hasher.combine(rssi)
    }

    var body: some View {
        ZStack {
            Color("SafeColor")
                .edgesIgnoringSafeArea(.all)
            VStack {
                Text("First Page")
                    .font(.largeTitle)
                    .padding()
                
                Text("Device Name: \(deviceName)")
                    .font(.title2)
                    .padding()
                
                Text("RSSI: \(rssi)")
                    .font(.title2)
                    .padding()
                
                NavigationLink(destination: SecondPage()) {
                    Text("Go to Second Page")
                }
                .padding()
            }
        }
        .navigationTitle("First Page")
    }
}

struct FirstPage_Previews: PreviewProvider {
    static var previews: some View {
        FirstPage(deviceName: "Sample Device", rssi: -70)
    }
}
