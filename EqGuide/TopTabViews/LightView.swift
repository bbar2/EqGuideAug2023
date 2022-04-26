//
//  LightView.swift
//  EqGuide
//
//  Created by Barry Bryant on 4/23/22.
//

import SwiftUI

let minRed = 64.0
let maxRed = 255.0
let initRed = 159.0 // matches appRed font color

struct LightView: View {
  
  @State private var redLevel = initRed
  @State private var isEditing = false
  
  var body: some View {
    ZStack {
      Rectangle()
        .fill(Color(red:redLevel / 255.0, green: 0, blue: 0))
        .ignoresSafeArea(edges:[.top])
      Slider(value: $redLevel, in: minRed...maxRed)
        .padding([.leading, .trailing], 20)
        .accentColor(.black)
    }
    .onAppear(){
      softBump()
    }

  }
}

struct LightView_Previews: PreviewProvider {
  static var previews: some View {
    LightView()
  }
}
