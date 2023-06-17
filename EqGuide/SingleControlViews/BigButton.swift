//
//  BigButton.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/29/22.
//

import SwiftUI

struct BigButton: View {
  var label:String
  var minWidth = 100
  var textColor: Color?
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
    .frame(minHeight: 75)
    .frame(minWidth: CGFloat(minWidth))
    .background(viewOptions.thumbColor)
    .foregroundColor(textColor ?? viewOptions.appActionColor)
    .cornerRadius(20)
  }
}

struct BigButton_Previews: PreviewProvider {
  static var previews: some View {
    BigButton(label: "Test"){}
      .environmentObject(ViewOptions())
  }
}
