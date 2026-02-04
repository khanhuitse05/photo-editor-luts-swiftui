//
//  ExportView.swift
//  colorful-room
//
//  Created by macOS on 7/23/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI

struct ExportView: View {
    
    @State var shared:ExportController = ExportController()
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
                        self.shared.resetExport()
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
                ScrollView(.horizontal, showsIndicators: false){
                    HStack(spacing: 24){
                        Spacer().frame(width: 8)
                        VStack{
                            if let origin = self.shared.originExport{
                                Image(uiImage: origin)
                                    .resizable()
                                    .modifier(ImageBorder())
                            }else{
                                Rectangle()
                                    .fill(Color.myPanel)
                                    .frame(width: self.shared.originRatio * 320)
                            }
                            
                            Button(action:{
                                self.shared.exportOrigin()
                                self.showSuccessPopup = true
                            }){
                                RaiseButton("Save picture")
                            }
                            .padding(.top, 24)
                        }
                       
                        Spacer().frame(width: 8)
                    }
                }
                .frame(height: 400)
                .clipped()
                Spacer()
                
                Spacer().frame(height: 16)
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())
        .alert(isPresented: $showSuccessPopup) {
            Alert(title: Text("Success"), message: Text("Your export success"), dismissButton: .default(Text("Close"), action: {
               
            })
            )
        }
        .onAppear(perform: {
            print("Export view: onAppear")
            shared.prepareExport()
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
