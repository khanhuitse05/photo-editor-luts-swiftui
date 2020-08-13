//
//  ExportView.swift
//  colorful-room
//
//  Created by macOS on 7/23/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI

struct ExportView: View {
    
    @EnvironmentObject var shared:PECtl
    @State private var showSheet:Bool = false
    @State private var showSuccessPopup = false
    
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        ZStack{
            Color.myBackground
                .edgesIgnoringSafeArea(.all)
            VStack{
                HStack{
                    Spacer()
                    Button(action:{
                        self.presentationMode.wrappedValue.dismiss()
                    }){
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .padding(.trailing)
                
                Text("Export your photo")
                    .font(.system(size: 26, weight: .semibold))
                    .multilineTextAlignment(.center)
                Text("You can download all that apply in your filter.\nAlways for FREE")
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.myGray)
                    .padding()
                
                Spacer()
                VStack{
                    Image(uiImage: self.shared.image!)
                        .resizable()
                        .scaledToFit()
                        .border(Color.white, width: 1)
                        .padding(.horizontal)
                    
                    
                    Button(action:{
                        self.shared.exportOrigin()
                        self.showSuccessPopup = true
                    }){
                        RaiseButton("Save picture")
                    }
                    .padding(.top, 24)
                }
                .frame(height: 400)
                .clipped()
                Spacer()
                NavigationLink(destination: SupportView()
                    .navigationBarTitle("")
                    .navigationBarHidden(true)){
                        HStack(alignment: .center, spacing: 16){
                            Spacer()
                            Image("emoji-support")
                                .renderingMode(.original)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 17)
                            
                            Text("SUPPORT OUR TEAM")
                            Image(systemName: "chevron.right")
                            Spacer()
                        }
                            
                        .padding()
                        .foregroundColor(.white)
                        .font(.system(size: 13))
                }
                Spacer().frame(height: 16)
                Button(action: {
                    self.showSheet = true
                }){
                    VStack{
                        HStack(alignment: .center){
                            Spacer()
                            Image(systemName: "hand.point.right")
                            Text("PRODUCT ROAD MAP")
                            Image(systemName: "chevron.up")
                            Spacer()
                        }
                        .foregroundColor(Color.myGrayLight)
                        Text("We ​​are developing for the future")
                            .foregroundColor(Color.myGray)
                    }
                    .font(.system(size: 14))
                }
                Spacer().frame(height: 16)
                
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())
            
        .sheet(isPresented: $showSheet){
            RoadMapView()
        }.alert(isPresented: $showSuccessPopup) {
            Alert(
                title: Text("Success"),
                message: Text("Your export success"),
                dismissButton: .default(Text("Close"), action: {})
            )
        }
        .onAppear(perform: {
            print("Export view: onAppear")
            PECtl.shared.didReceive(action: .commit)
        })
    }
}

struct ExportView_Previews: PreviewProvider {
    static var previews: some View {
        let shared = PECtl.shared
        shared.originUI = UIImage(named: "carem")
        return ExportView()
            .background(Color(UIColor.systemBackground))
            .environment(\.colorScheme, .dark)
            .environmentObject(shared)
    }
}
