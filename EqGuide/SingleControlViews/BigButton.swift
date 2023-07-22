//
//  BigButton.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/29/22.
//

import SwiftUI

struct BigButton: View {
  var label:String?
  var textColor: Color?
  var minWidth = 100
  var minHeight = 75
  var image: Image?   // image will override label
  var imageSize: CGFloat?
  var action: ()->Void
  
  @EnvironmentObject var viewOptions: ViewOptions
  
  var body: some View {
    
    Button() {
      action()
    } label: {
      if let buttonImage = image {
        buttonImage
          .resizable(capInsets: EdgeInsets(), resizingMode: .stretch)
          .aspectRatio(1.0, contentMode: .fit)
          .padding([.all], 20)
      }
      else {
        Text(self.label ?? "PushMe")
          .font(.title)
          .bold()
          .padding([.top, .bottom], 05)
          .padding([.leading, .trailing], 20)
      }
    }
    .frame(minHeight: CGFloat(minHeight))
    .frame(minWidth: CGFloat(minWidth))
    .frame(width:imageSize, height:imageSize)
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
