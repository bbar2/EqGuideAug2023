
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

  static func targetTapAction(_: Target) {
  }
  
  static var previews: some View {
    TargetListView(catalog: guideModel.catalog,
    targetTapAction: targetTapAction)
  }
}
