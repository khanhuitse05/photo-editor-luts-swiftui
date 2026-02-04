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
        
        NavigationStack {
            ZStack(alignment: .top) {
                Color.myBackground
                    .ignoresSafeArea(.all)
                SwiftUI.Image("intro-image")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: CGFloat(imageHeight))
                    .ignoresSafeArea(edges: .top)
                
                VStack(alignment: .center, spacing: 24) {
                    Spacer()
                    HStack {
                        Text("Create your\ncool filter")
                            .font(.system(size: 32, weight: .semibold))
                            .fontWeight(.semibold)
                            .padding(.leading, 22)
                        Spacer()
                    }
                    VStack(spacing: 24) {
                        ForEach(K.introContent, id: \.["title"]) { item in
                            ListTitle(
                                title: item["title"],
                                supTitle: item["supTitle"],
                                leadingImage: item["leadingImage"],
                                highlight: item["highlight"]
                            )
                        }
                    }
                    Spacer().frame(height: 0)
                    
                    Button {
                        showSheet = true
                        showImageEdit = false
                        inputImage = nil
                    } label: {
                        ZStack {
                            Rectangle()
                                .fill(Color.white)
                                .frame(height: 52)
                                .frame(maxWidth: .infinity)
                            HStack(alignment: .center, spacing: 10) {
                                SwiftUI.Image("icon-photo-add")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(Color.black)
                                    .frame(width: 18, height: 18)
                                Text("CHOOSE YOUR PICTURE")
                                    .font(.headline)
                                    .foregroundStyle(Color.black)
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    .buttonStyle(.plain)
                    
                    Spacer().frame(height: 0)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $showImageEdit) {
                PhotoEditView(image: inputImage)
            }
        }
        .sheet(isPresented: $showSheet, onDismiss: loadImage){
            ImagePicker(image: self.$pickImage)
        }.onAppear(perform: {
            // self.pickImage = UIImage(named: "carem")
            // self.loadImage()
            
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
                .environment(PECtl.shared)
                .environmentObject(Data.shared)
        }
    }
}
