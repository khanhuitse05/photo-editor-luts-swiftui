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
    
    
    var body: some View {
        
        NavigationStack {
            GeometryReader { geometry in
                ZStack(alignment: .center) {
                    SwiftUI.Image("intro-image")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .ignoresSafeArea(.all)
                    
                    
                    VStack {
                        Spacer()
                        
                        VStack(alignment: .center, spacing: 24) {
                            Text("Make It Pop")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.myAccent.opacity(0.6), Color.myAccent.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .padding(.horizontal, 16)
                                .shadow(color: Color.myAccent.opacity(0.3), radius: 8, x: 0, y: 4)
                                .overlay {
                                    Text("Make It Pop")
                                        .font(.system(size: 32, weight: .bold, design: .rounded))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [.white.opacity(0.4), .clear],
                                                startPoint: .top,
                                                endPoint: .center
                                            )
                                        )
                                        .blendMode(.overlay)
                                }
                            VStack(spacing: 4) {
                                ForEach(K.introContent, id: \.["title"]) { item in
                                    ListTitle(
                                        title: item["title"],
                                        supTitle: item["supTitle"],
                                        leadingImage: item["leadingImage"],
                                        highlight: item["highlight"]
                                    )
                                    .padding(.vertical, 8)
                                    .glassCard(cornerRadius: 12)
                                }
                            }
                            .padding(.horizontal, 16)
                            Spacer().frame(height: 0)
                            
                            Button {
                                showSheet = true
                                showImageEdit = false
                                inputImage = nil
                            } label: {
                                Label("Choose Your Picture", systemImage: "photo.badge.plus")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.white)
                            }
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                            .glassEffect(.regular.tint(Color.myAccent.opacity(0.6)).interactive(), in: .rect(cornerRadius: 16))
                            .overlay {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.white.opacity(0.3), .clear],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            }
                            .shadow(color: Color.myAccent.opacity(0.2), radius: 12, x: 0, y: 4)
                            .padding(.horizontal, 30)
                            
                            Spacer().frame(height: 0)
                        }
                        .padding(.vertical, 24)
                        .frame(width: geometry.size.width)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .ignoresSafeArea(.all)
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
