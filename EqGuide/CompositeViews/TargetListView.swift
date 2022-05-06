
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
  
  var body: some View {
    List(catalog){
      let gestureTarget = $0
      TargetRow(target: $0)
        .gesture(TapGesture().onEnded() { targetTapAction(gestureTarget) } )
    }
  }
}

struct ObjectListView_Previews: PreviewProvider {
  @State static var guideModel = GuideModel()
  static func targetTapAction(_ target: Target) {
    tappedTarget = target
  }
  @State static var tappedTarget = guideModel.catalog[0]

  static var previews: some View {
    VStack {
      Text(tappedTarget.name)
      TargetListView(catalog: guideModel.catalog,
                     targetTapAction: targetTapAction)
    }
  }
}
