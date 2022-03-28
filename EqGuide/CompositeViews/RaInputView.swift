//
//  RaInputView.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/27/22.
//

import SwiftUI

struct RaInputView: View {

  var label:String
  @Binding var coord:RaDec

  var body: some View {
    VStack {
      Text(label).font(.title)
      Text("Input RA and Dec Degrees")
    }
    .onAppear() { coord.ra = 90.0}
  }
}

struct RaInputView_Previews: PreviewProvider {
  @State static var crap = RaDec(ra:97.5, dec: 0.5)
    static var previews: some View {
      RaInputView(label: "Enter RA/DEC Pair", coord: $crap)
    }
}
