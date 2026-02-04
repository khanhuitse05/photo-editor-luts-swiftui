//
//  RoadMapView.swift
//  colorful-room
//
//  Created by Ping9 on 8/3/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI

struct RoadMapView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack(alignment: .top){
            Color(uiColor: .systemBackground)
                .ignoresSafeArea(.all)
            ScrollView(showsIndicators: false){
                VStack(alignment: .leading, spacing: 8){
                    HStack{
                        Spacer()
                        Button("Close", action: {
                            self.dismiss()
                        })
                            .foregroundStyle(.secondary)
                            .padding()
                    }
                    Text("Product\nRoad map")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .frame(height: 110)
                    
                    Text(K.roadMapDescription)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.vertical)
                    Text("What are we doing?")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .padding(.vertical)
                    
                    Group{
                        ForEach(K.roadMapConttent, id: \.["title"]){item in
                        RoadStepView(title: item["title"] ?? "",
                                     content: item["body"] ?? "",
                                     date: item["date"] ?? "",
                                     highLight: item["highLight"] == "true")
                        }
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
                        .fill(Color(uiColor: .tertiaryLabel))
                        .frame(width: 10, height: 10)
                }
                Rectangle()
                    .fill(Color(uiColor: .separator))
                    .frame(width: 1)
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
            VStack(alignment: .leading){
                Text(self.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(highLight ? .primary : .secondary)
                    .padding(.bottom, 10)
                
                Text(self.content)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(self.date.uppercased())
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.vertical, 8)
            }
        }
    }
}
