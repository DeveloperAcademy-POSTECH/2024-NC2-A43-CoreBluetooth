import SwiftUI

struct FirstPage: View {
    var body: some View {
        ZStack{
            Color("SafeColor")
                .edgesIgnoringSafeArea(.all)
            VStack {
                Text("First Page")
                    .font(.largeTitle)
                    .padding()
                
                NavigationLink(destination: SecondPage()) {
                    Text("Go to Second Page")
                }
                .padding()
            }
            .navigationTitle("First Page")
        }
    }
}

struct FirstPage_Previews: PreviewProvider {
    static var previews: some View {
        FirstPage()
    }
}
