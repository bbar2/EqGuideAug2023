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
  var labelRa = "RA"
  var labelDec = "Dec"
  
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
          HStack{
            Text(labelRa)
            Text(Hms(pair.ra).string(unitHmsDms))
          }
          
          HStack {
            Text(labelDec)
            Text(Dms(pair.dec).string(unitHmsDms))
          }
        }
        .padding([.trailing], gapPad/2)
        .font(viewOptions.bigValueFont)
      }
    }
  }
}

struct raDecPairView_Previews: PreviewProvider {
  static let viewOptions = ViewOptions()
  static let pair = RaDec(ra:3.33, dec:2.22)
  static var previews: some View {
    Group {
      RaDecPairView(pairTitle: "Title", pair: pair, unitHmsDms: true)
      RaDecPairView(pairTitle: "Title", pair: pair, unitHmsDms: false)
    }
    .environmentObject(viewOptions)
    .previewLayout(.fixed(width: 400, height: 150))

  }
}



//var body: some View {
//
//  VStack{
//
//    Divider()
//
//    Text(pairTitle).font(viewOptions.labelFont)
//
//    HStack {
//      HStack{
//        Text(labelRa)
//        Text(Hms(pair.ra).string(unitHmsDms))
//      }
//      .padding([.trailing], gapPad/2)
//
//      HStack {
//        Text(labelDec)
//        Text(Dms(pair.dec).string(unitHmsDms))
//      }
//      .padding([.leading], gapPad/2)
//    }
//    .font(viewOptions.bigValueFont)
//  }
//}
//}
