import SwiftUI

struct ThirdPage: View {
    var body: some View {
        ZStack{
            Color("WarningColor")
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Third Page")
                    .font(.largeTitle)
                    .padding()
                
                NavigationLink(destination: FourthPage()) {
                    Text("Go to Fourth Page")
                }
                .padding()
            }
            .navigationTitle("Third Page")
        }
    }
}

struct ThirdPage_Previews: PreviewProvider {
    static var previews: some View {
        ThirdPage()
    }
}
