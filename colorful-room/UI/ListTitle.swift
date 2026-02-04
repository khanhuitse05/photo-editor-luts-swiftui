//
//  ListTitle.swift
//  colorful-room
//
//  Created by macOS on 7/16/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI

struct ListTitle: View {
    
    var title:String
    var supTitle:String
    var leadingImage:String
    var highlight:String
    
    init(title:String?, supTitle:String?, leadingImage:String?, highlight:String? = "") {
        self.title = title ?? ""
        self.supTitle = supTitle ?? ""
        self.leadingImage = leadingImage ?? ""
        self.highlight = highlight ?? ""
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 0){
            Image(leadingImage)
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
                .padding(.trailing, 20)
            VStack(alignment: .leading, spacing: 4){
                HStack(spacing: 8){
                    Text(title)
                        .font(.system(size: 15, weight: .medium))
                        .multilineTextAlignment(.leading)
                    if(highlight.isEmpty == false){
                        Text(highlight)
                            .font(.system(size: 12, weight: .medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.myPrimary)
                            .cornerRadius(2)
                    }
                    Spacer()
                }
                
                Text(supTitle)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.gray)
            }
            Spacer()
        }.padding(.horizontal, 24)
    }
}

struct ListTitle_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            ListTitle(
                title: "Free and Premium Filters",
                supTitle: "Export your picture, Lookup image, all effects, and more",
                leadingImage: "edit-lut",
                highlight: "AR filter"
            )
                .background(Color(UIColor.systemBackground))
                .environment(\.colorScheme, .dark)
        }
    }
}
