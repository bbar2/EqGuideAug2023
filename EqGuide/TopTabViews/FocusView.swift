//
//  FocusView.swift
//  EqGuide
//
//  Created by Barry Bryant on 4/8/22.
//

import SwiftUI

struct FocusView: View {
  var body: some View {
    Text("Insert Focus App Here")
      .onAppear(){
        softBump()
      }
    
  }
}

struct FocusView_Previews: PreviewProvider {
  static var previews: some View {
    FocusView()
  }
}
