//
//  ContentView.swift
//  colorful-room
//
//  Created by macOS on 7/3/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI
import UIKit
import PixelEnginePackage

struct ContentView: View {
    
    @State private var showSheet = false
    
    @State private var showImageEdit = false
    // for pick view
    @State private var pickImage: UIImage?
    // for edit view
    @State private var inputImage: UIImage?
    
    
    let imageHeight:Double = 355
    
    var body: some View {
        
        NavigationView{
            ZStack(alignment: .top){
                Color.myBackground
                    .edgesIgnoringSafeArea(.all)
                Image("intro-image")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: CGFloat(imageHeight))
                    .edgesIgnoringSafeArea(.top)
                
                GeometryReader { geo in
                    VStack(alignment: .center, spacing: 24){
                        Spacer()
                        HStack{
                            Text("Create your\ncool filter")
                                .font(.system(size: 32, weight: .semibold))
                                .fontWeight(.semibold)
                                .padding(.leading, 22)
                            Spacer()
                        }
                        VStack(spacing: 24){
                            ForEach(K.introContent, id: \.["title"]){item in
                                ListTitle(
                                    title: item["title"],
                                    supTitle: item["supTitle"],
                                    leadingImage: item["leadingImage"],
                                    highlight: item["highlight"]
                                )
                            }
                        }
                        Spacer().frame(height: 0)
                        
                        ZStack{
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: geo.size.width - 60, height: 52)
                            HStack(alignment: .center, spacing: 10){
                                
                                Image("icon-photo-add")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(Color.black)
                                    .frame(width: 18, height: 18)
                                Text("CHOOSE YOUR PICTURE")
                                    .font(.headline)
                                    .foregroundColor(Color.black)
                                
                            }
                            .onTapGesture {
                                self.showSheet = true
                                self.showImageEdit = false
                                self.inputImage = nil
                            }
                        }
                        
                        NavigationLink(destination: SupportView()
                            .navigationBarTitle("")
                            .navigationBarHidden(true)
                        ){
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
                        NavigationLink(destination: PhotoEditView(image: self.inputImage)
                            .navigationBarTitle("")
                            .navigationBarHidden(true), isActive: self.$showImageEdit) {
                                EmptyView()
                        }.hidden()
                        
                    }
                }
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showSheet, onDismiss: loadImage){
            ImagePicker(image: self.$pickImage)
        }.onAppear(perform: {
            print("onAppear")
            // todo: for development
//            self.pickImage = UIImage(named: "carem")
//            self.loadImage()
            
        })
        
    }
    
    func loadImage(){
        print("loadImage: \(pickImage != nil)")
        guard self.pickImage != nil else {
            return
        }
        self.inputImage = self.pickImage
        self.showImageEdit = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .background(Color(UIColor.systemBackground))
                .environment(\.colorScheme, .dark)
                .environmentObject(PECtl.shared)
                .environmentObject(Data.shared)
        }
    }
}
