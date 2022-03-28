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
  
  var body: some View {
    VStack{
      Divider()
      Text(pairTitle)
        .font(.headline).bold()
      
      HStack {
        VStack {
          Text("RA").font(.subheadline).bold()
          HmsView(angle: pair.ra)
        }
        
        Spacer()
        
        VStack {
          Text("DEC").font(.subheadline).bold()
          DmsView(angle: pair.dec)
        }
      }
      .padding([.leading, .trailing], 45)
      Divider()
    }
    
  }
}

struct raDecPairView_Previews: PreviewProvider {
  static let pair = RaDec(ra:3.33, dec:2.22)
    static var previews: some View {
      RaDecPairView(pairTitle: "Title", pair: pair)
    }
}
