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

  var minWidth = 100

  @State private var canTouchDown = true

  @EnvironmentObject var viewOptions: ViewOptions
  
  var body: some View {
    Image(systemName: systemName)
      .resizable()
      .frame(width: 120, height: 120)
    //.offset(x:canTouchDown ? 0 : 2, y:canTouchDown ? 0 : 2)
    .gesture(
      DragGesture(minimumDistance: 0)
        .onChanged { value in
          if canTouchDown {
            touchAction()
            canTouchDown = false
          }
        }
        .onEnded { value in
          releaseAction()
          canTouchDown = true
        }
    )
    .foregroundColor(canTouchDown == false ? viewOptions.appRedColor : viewOptions.appActionColor)
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
