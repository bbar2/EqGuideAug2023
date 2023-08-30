
//
//  ObjectListView.swift
//  Guide
//
//  Created by Barry Bryant on 12/19/21.
//

import SwiftUI

struct TargetListView: View {
  
  @EnvironmentObject var viewOptions: ViewOptions

  var catalog: [Target]
  var targetTapAction: (_: Target)->Void // let caller handle target taps
  var lstDeg: Double

  var body: some View {
    List(catalog){
      let gestureTarget = $0
      TargetRow(target: $0, lstDeg: lstDeg)
        .gesture(TapGesture().onEnded() { targetTapAction(gestureTarget) } )
    }
  }
}

struct ObjectListView_Previews: PreviewProvider {
  @State static var guideModel = MountBleModel()
  static func targetTapAction(_ target: Target) {
  }
  @State static var tappedTarget = guideModel.catalog[0]
  
  static var previews: some View {
    Group {
      TargetListView(catalog: guideModel.catalog,
                     targetTapAction: targetTapAction,
                     lstDeg: 0.0)
    }
  }
}
