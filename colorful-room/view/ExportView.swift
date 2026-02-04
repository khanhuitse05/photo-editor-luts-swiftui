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
    
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack{
            Color(uiColor: .systemBackground)
                .ignoresSafeArea(.all)
            VStack{
                HStack{
                    Spacer()
                    Button(action:{
                        self.shared.resetExport()
                        self.dismiss()
                    }){
                        Image(systemName: "xmark")
                    }
                    .buttonStyle(.glass)
                }
                .padding()
                .padding(.trailing)
                
                Text("Export your photo")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                Text("You can download all that apply in your filter.\nAlways for FREE")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
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
                                    .fill(Color(uiColor: .tertiarySystemFill))
                                    .frame(width: self.shared.originRatio * 320)
                            }
                            
                            Button(action:{
                                self.shared.exportOrigin()
                                self.showSuccessPopup = true
                            }){
                                Label("Save picture", systemImage: "arrow.down.to.line")
                                    .font(.subheadline)
                            }
                            .frame(minWidth: 160, minHeight: 48)
                            .buttonStyle(.glassProminent)
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
        .toolbar(.hidden, for: .navigationBar)
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
            .environment(shared)
    }
}
