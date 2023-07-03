//
//  MountChangeView.swift
//  EqGuide
//
//  Created by Barry Bryant on 10/1/22.
//

import SwiftUI

struct MountChangeView: View {
  var title: String
  var pierMoveDeg: Double = 0.0
  var diskMoveDeg: Double = 0.0
  
  var gapPad = 30.0

  @EnvironmentObject var viewOptions: ViewOptions

  var body: some View {
    
    VStack{
      
      Divider()
      
      HStack {
        Text(title)
          .font(viewOptions.labelFont)
          .multilineTextAlignment(.leading)

        Spacer()

        VStack (alignment: .leading){
          Text("Δ Pier")
          Text("Δ Disk")
        }
        .font(viewOptions.smallValueFont)

        VStack (alignment: .trailing){
          Text(String(format: "%+7.2fº", pierMoveDeg))
          Text(String(format: "%+7.2fº", diskMoveDeg))
        }
        .font(viewOptions.smallValueFont)
        .padding([.trailing], gapPad/2)

      }
    }
  }
}

struct MountChangeView_Previews: PreviewProvider {
  static let viewOptions = ViewOptions()
  static let pierMoveDeg = -123.456
  static let diskMoveDeg = 7.89
  static var previews: some View {
    MountChangeView(title: "Title", pierMoveDeg: pierMoveDeg, diskMoveDeg: diskMoveDeg)
      .environmentObject(viewOptions)
      .preferredColorScheme(.dark)
  }
}

