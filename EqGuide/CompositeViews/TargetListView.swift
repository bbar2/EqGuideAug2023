
//
//  ObjectListView.swift
//  Guide
//
//  Created by Barry Bryant on 12/19/21.
//

import SwiftUI

struct TargetListView: View {
  var catalog: [Target]
  var targetTapAction: (_: Target)->Void // let caller handle target taps
  var unitHmsDms: Bool
  
  var body: some View {
    List(catalog){
      let gestureTarget = $0
      TargetRow(target: $0, unitHmsDms: unitHmsDms)
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
                     unitHmsDms: true)
      TargetListView(catalog: guideModel.catalog,
                     targetTapAction: targetTapAction,
                     unitHmsDms: false)
    }
  }
}
