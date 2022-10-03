//
//  raDecPairView.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/26/22.
//

import SwiftUI

struct RaDecPairView: View {
  var pairTitle: String
  var pair: RaDec
  var unitHmsDms: Bool
  var armDeg: Double = 0.0
  var dskDeg: Double = 0.0
  
  var gapPad = 30.0

  @EnvironmentObject var viewOptions: ViewOptions

  var body: some View {
    
    VStack{
      
      Divider()
      
      HStack {
        Text(pairTitle)
          .font(viewOptions.labelFont)
          .multilineTextAlignment(.leading)
        Spacer()
        VStack (alignment: .trailing){
          Text("RA")
          Text("Dec")
        }
        .font(viewOptions.smallValueFont)

        VStack (alignment: .trailing){
          Text(Hms(pair.ra).string(unitHmsDms))
          Text(Dms(pair.dec).string(unitHmsDms))
        }
        .font(viewOptions.smallValueFont)

        Spacer()
        VStack (alignment: .trailing) {
          Text("Arm")
          Text("Dsk")
        }
        .font(viewOptions.smallValueFont)
        VStack (alignment: .trailing) {
          Text(String(format: "%+7.2fº", armDeg))
          Text(String(format: "%+7.2fº", dskDeg))
        }
        .font(viewOptions.smallValueFont)
        .padding([.trailing], gapPad/2)
      }
    }
  }
}

struct raDecPairView_Previews: PreviewProvider {
  static let viewOptions = ViewOptions()
  static let pair = RaDec(ra:3.33, dec:2.22)
  static var previews: some View {
    Group {
      RaDecPairView(pairTitle: "Title: \nextraText", pair: pair, unitHmsDms: true)
      RaDecPairView(pairTitle: "Title", pair: pair, unitHmsDms: false)
    }
    .environmentObject(viewOptions)
    .previewLayout(.fixed(width: 400, height: 150))
    .preferredColorScheme(.dark)
  }
}



