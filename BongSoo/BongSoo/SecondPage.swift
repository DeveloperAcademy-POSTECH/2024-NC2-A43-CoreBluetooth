import SwiftUI

struct SecondPage: View {
    var body: some View {
        ZStack{
            Color("AttentionColor")
                .edgesIgnoringSafeArea(.all)
            VStack {
                Text("Second Page")
                    .font(.largeTitle)
                    .padding()
                
                NavigationLink(destination: ThirdPage()) {
                    Text("Go to Third Page")
                }
                .padding()
            }
            .navigationTitle("Second Page")
        }
    }
}

struct SecondPage_Previews: PreviewProvider {
    static var previews: some View {
        SecondPage()
    }
}
