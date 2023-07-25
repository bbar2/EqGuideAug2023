//
//  BigButton.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/29/22.
//

import SwiftUI

struct TouchImage: View {
  var systemName:String
  var touchAction: ()->Void
  var releaseAction: ()->Void
  var enable: Bool = true

  @State private var canTouchDown = true

  @EnvironmentObject var viewOptions: ViewOptions
  
  var body: some View {
    Image(systemName: systemName)
      .resizable()
      .frame(width: 100, height: 90)
    //.offset(x:canTouchDown ? 0 : 2, y:canTouchDown ? 0 : 2)
    .gesture(
      DragGesture(minimumDistance: 0)
        .onChanged { value in
          if enable {
            if canTouchDown {
              touchAction()
              canTouchDown = false
            }
          }
        }
        .onEnded { value in
          if enable {
            releaseAction()
            canTouchDown = true
          }
        }
    )
    .foregroundColor(enable ? (canTouchDown == false ? viewOptions.appRedColor : viewOptions.appActionColor) : viewOptions.appDisabledColor)
  }
}

struct TouchImage_Previews: PreviewProvider {
  static var nullAction: ()->Void = {}
  static var previews: some View {
    TouchImage(systemName: "arrowtriangle.forward",
               touchAction: nullAction,
               releaseAction: nullAction)
      .environmentObject(ViewOptions())
      .preferredColorScheme(.dark)

  }
}
