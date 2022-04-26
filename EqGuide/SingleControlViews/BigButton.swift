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
  
  @EnvironmentObject var viewOptions: ViewOptions
  
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
    .background(viewOptions.thumbColor)
    .foregroundColor(viewOptions.appActionColor)
    .cornerRadius(20)
  }
}

struct BigButton_Previews: PreviewProvider {
  static var previews: some View {
    BigButton(label: "Test"){}
      .environmentObject(ViewOptions())
  }
}
