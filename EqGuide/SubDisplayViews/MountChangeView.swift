//
//  MountChangeView.swift
//  EqGuide
//
//  Created by Barry Bryant on 10/1/22.
//

import SwiftUI

struct MountChangeView: View {
  var title: String
  var armMoveDeg: Double = 0.0
  var dskMoveDeg: Double = 0.0
  
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
          Text("Δ Arm")
          Text("Δ Dsk")
        }
        .font(viewOptions.smallValueFont)

        VStack (alignment: .trailing){
          Text(String(format: "%+7.2fº", armMoveDeg))
          Text(String(format: "%+7.2fº", dskMoveDeg))
        }
        .font(viewOptions.smallValueFont)
        .padding([.trailing], gapPad/2)

      }
    }
  }
}

struct MountChangeView_Previews: PreviewProvider {
  static let viewOptions = ViewOptions()
  static let armMoveDeg = -123.456
  static let dskMoveDeg = 7.89
  static var previews: some View {
    MountChangeView(title: "Title", armMoveDeg: armMoveDeg, dskMoveDeg: dskMoveDeg)
      .environmentObject(viewOptions)
      .preferredColorScheme(.dark)
  }
}

