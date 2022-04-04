//
//  raDecPairView.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/26/22.
//

import SwiftUI

struct RaDecPairView: View {
  var pairTitle:String
  var pair:RaDec
//  var pairRa: Float
//  var pairDec: Float
  
  var gapPad = 30.0
  
  var body: some View {
    VStack{
      Divider()

      Text(pairTitle)
        .font(.headline).bold()
      
      HStack {
        HStack{
          Text("RA").font(.subheadline).bold()
          HmsView(angleDegrees: pair.ra)
        }
        .padding([.trailing], gapPad/2)
        
        HStack {
          Text("DEC").font(.subheadline).bold()
          DmsView(angleDegrees: pair.dec)
        }
        .padding([.leading], gapPad/2)
      }

    }
    
  }
}

struct raDecPairView_Previews: PreviewProvider {
  static let pair = RaDec(ra:3.33, dec:2.22)
    static var previews: some View {
      RaDecPairView(pairTitle: "Title", pair: pair)
    }
}
