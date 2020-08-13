//
//  RoadMapView.swift
//  colorful-room
//
//  Created by Ping9 on 8/3/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI

struct RoadMapView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        ZStack(alignment: .top){
            Color.myBackground
                .edgesIgnoringSafeArea(.all)
            ScrollView(showsIndicators: false){
                VStack(alignment: .leading, spacing: 8){
                    HStack{
                        Spacer()
                        Button("Close", action: {
                            self.presentationMode.wrappedValue.dismiss()
                        })
                            .foregroundColor(Color.myGrayLight)
                            .padding()
                    }
                    Text("Product\nRoad map")
                        .font(.system(size: 36, weight: .semibold ))
                        .foregroundColor(Color.myGrayLight)
                        .frame(height: 110)
                    
                    Text("Your great contribution will help our team a lot to continue developing better product.")
                        .font(.system(size: 15))
                        .foregroundColor(Color.gray)
                        .padding(.vertical)
                    Text("What are we doing?")
                        .font(.system(size: 15, weight: .semibold ))
                        .foregroundColor(Color.myGrayLight)
                        .padding(.vertical)
                    
                    Group{
                        RoadStepView(title: "Lauching MVP - Beta version", content: "Basic editor, include HLS editor, export your picture and LUTs image", date: "August 15, 2020", highLight: true)
                        RoadStepView(title: "Lauching Production v1.1", content: "You can crop image, import more LUTs templates", date: "September 10 ,2020")
                        RoadStepView(title: "Add Effect tool & export all effect", content: "You can add effect and export all effects image that you can use for AR filter", date: "December 1 ,2020")
                        RoadStepView(title: "Export Spark AR filter", content: "You can export Spark AR project file when done editing!", date: "2021")
                    }
                    
                }.padding()
            }
        }
    }
}

struct RoadMapView_Previews: PreviewProvider {
    static var previews: some View {
        RoadMapView()
    }
}


struct RoadStepView: View{
    
    var title:String
    var content:String
    var date:String
    
    var highLight = false
    
    var body: some View{
        HStack{
            VStack{
                if(highLight){
                    Circle()
                        .fill(Color.purple)
                        .frame(width: 10, height: 10).overlay(
                            RoundedRectangle(cornerRadius: 40)
                                .stroke(Color(red: 1, green: 0.33, blue: 1, opacity: 0.3), lineWidth: 8)
                        )
                }else{
                    Circle()
                        .fill(Color.myGray)
                        .frame(width: 10, height: 10)
                }
                Rectangle()
                    .fill(Color.myGrayDark)
                    .frame(width: 1)
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
            VStack(alignment: .leading){
                Text(self.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(highLight ? Color.myGrayLight : Color.myGray)
                    .padding(.bottom, 10)
                
                Text(self.content)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color.myGray)
                
                Text(self.date.uppercased())
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(Color.myGrayDark)
                    .padding(.vertical, 8)
            }
        }
    }
}
