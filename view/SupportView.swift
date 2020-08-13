//
//  SupportView.swift
//  colorful-room
//
//  Created by macOS on 7/19/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI

struct SupportView: View {
    
    let padding:CGFloat = 24
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var showSheet:Bool = false
    
    var body: some View {
        NavigationView{
            ZStack(alignment: .top){
                Color.myBackground
                    .edgesIgnoringSafeArea(.all)
                Image("pattern-top")
                    .resizable()
                    .scaledToFit()
                    .edgesIgnoringSafeArea(.top)
                
                ScrollView(showsIndicators: false){
                    VStack(alignment: .leading, spacing: 0){
                        HStack{
                            Button(action:{
                                self.presentationMode.wrappedValue.dismiss()
                            }){
                                Text("BACK")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                    .padding(.vertical)
                                    .padding(.horizontal, padding)
                            }
                            Spacer()
                        }
                        Spacer().frame(height: 50)
                        Group{
                            HStack{
                                Text("We are")
                                    .font(.system(size: 36, weight: .semibold))
                                Image("icon-heart").resizable().scaledToFit().frame(width: 26)
                            }
                            .padding(.horizontal, padding)
                            Text("always free!")
                                .font(.system(size: 36, weight: .semibold))
                                .padding(.horizontal, padding)
                            Text("& give you the best features")
                                .font(.system(size: 15, weight: .semibold))
                                .padding(.horizontal, padding)
                                .padding(.vertical, 8)
                            Spacer().frame(height: 24)
                            Text("However, we also need your support to continue improving the app and serve you better. We are really appreciated for that!")
                                .font(.system(size: 14))
                                .foregroundColor(Color.myGray)
                                .padding(.horizontal, padding)
                        }
                        
                        Spacer().frame(height: 32)
                      
                        VStack(alignment: .leading, spacing: 0){
                            Group{
                                
                                Text("BASIC SUPPORT")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color.myGray)
                                    .padding(.horizontal, padding)
                                    .padding(.vertical, 16)
                                ScrollView(.horizontal, showsIndicators: false){
                                    HStack(spacing: 12){
                                        Spacer().frame(width: 8)
                                            MinerDonate(value: 2.99)
                                            MinerDonate(value: 3.99)
                                            MinerDonate(value: 4.99)
                                        
                                        Spacer().frame(width: 8)
                                    }
                                }
                            }
                            Spacer().frame(height: 32)
                            Group{
                                Text("SUPER SUPPORT")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color.myGray)
                                    .padding(.horizontal, padding)
                                    .padding(.vertical, 16)
                                ScrollView(.horizontal, showsIndicators: false){
                                    HStack(spacing: 16){
                                        Spacer().frame(width: 8)
                                        MajorDonate(value: 39.99, image: "icon-gold", color: Color("gold"))
                                   
                                        MajorDonate(value: 29.99,image: "icon-silver", color: Color("sliver"))
                                   
                                        MajorDonate(value: 19.99, image: "icon-bronze", color: Color("bronze"))
                                       
                                        Spacer().frame(width: 8)
                                    }
                                }
                            }
                        }
                        Spacer().frame(height: 15)
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
                        Spacer().frame(height: 32)

                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .sheet(isPresented: $showSheet, content: {RoadMapView()})
    }
    
    
}

struct SupportView_Previews: PreviewProvider {
    static var previews: some View {
        SupportView()
            .background(Color(UIColor.systemBackground))
            .environment(\.colorScheme, .dark)
    }
}

struct MinerDonate : View{
    var value:Double
    
    var body: some View{
        
        Text("$\(value, specifier: "%.2f")")
            .frame(width: 103, height: 50, alignment: .center)
            .background(Color.myDivider)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.myGray, lineWidth: 2))
            .cornerRadius(6)
            .gesture(
                TapGesture()
                    .onEnded { _ in
                        
                        
                }
        )
    }
}

struct MajorDonate : View {
    
    var value:Double
    var image:String
    var color:Color
    
    var body: some View{
        VStack(spacing: 16){
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(height: 68)
            Text("$\(value, specifier: "%.2f")")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
        }
        .frame(width: 140, height: 147, alignment: .center)
        .background(Color.myDivider)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(color, lineWidth: 1.5))
            .gesture(
                TapGesture()
                    .onEnded { _ in
                       
                }
        )
    }
}
