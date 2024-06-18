import SwiftUI

struct FourthPage: View {
    var body: some View {
        ZStack{
            Color("DangerousColor")
                .edgesIgnoringSafeArea(.all)
            VStack {
                Text("Fourth Page")
                    .font(.largeTitle)
                    .padding()
            }
            .navigationTitle("Fourth Page")
        }
    }
}

struct FourthPage_Previews: PreviewProvider {
    static var previews: some View {
        FourthPage()
    }
}
