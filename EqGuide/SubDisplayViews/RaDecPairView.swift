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
  var showDmsHms: Bool = false
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
          Text(Hms(pair.ra).string(showDmsHms))
          Text(Dms(pair.dec).string(showDmsHms))
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
    RaDecPairView(pairTitle: "Title: \nextraText", pair: pair)
    .environmentObject(viewOptions)
    .previewLayout(.fixed(width: 400, height: 150))
    .preferredColorScheme(.dark)
  }
}



