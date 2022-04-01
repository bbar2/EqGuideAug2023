//
//  BigButton.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/29/22.
//

import SwiftUI

struct BigButton: View {
  var label:String
  var action: ()->Void
  
  var body: some View {
    Button() {
      action()
    } label: {
      Text(self.label)
        .font(.title)
        .bold()
    }
    .frame(height: 75)
    .frame(minWidth: 100)
    .background(Color(red:0.9, green:0.9, blue:0.9))
    .cornerRadius(20)
  }
}

struct BigButton_Previews: PreviewProvider {
  static var previews: some View {
    BigButton(label: "Test"){}
  }
}
