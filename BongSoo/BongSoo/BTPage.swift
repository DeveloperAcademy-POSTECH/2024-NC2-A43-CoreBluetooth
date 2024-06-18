import SwiftUI

struct BTPage: View {
    @EnvironmentObject var pathHolder: NavigationPathHolder

    var body: some View {
        VStack {
            NavigationLink(destination: FirstPage().environmentObject(pathHolder)) {
                Text("Go to First Page")
            }
            .padding()

            NavigationLink(destination: SecondPage().environmentObject(pathHolder)) {
                Text("Go to Second Page")
            }
            .padding()

            NavigationLink(destination: ThirdPage().environmentObject(pathHolder)) {
                Text("Go to Third Page")
            }
            .padding()

            NavigationLink(destination: FourthPage().environmentObject(pathHolder)) {
                Text("Go to Fourth Page")
            }
            .padding()
        }
        .navigationTitle("BTPage")
    }
}

struct BTPage_Previews: PreviewProvider {
    static var previews: some View {
        BTPage()
            .environmentObject(NavigationPathHolder())
    }
}
