//
//  guideView.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/27/22.
//

import SwiftUI

struct GuideView: View {
  @ObservedObject var mountModel: MountBleModel

  @EnvironmentObject var viewOptions: ViewOptions
  
  var gdb:MountDataBlock {
    mountModel.mountDataBlock
  }
  
  var mountStateString:String {
    let stateEnum = MountState(rawValue: gdb.mountState)
    let stateString:String = "\(stateEnum ?? MountState.StateError)"
    return(stateString)
  }
  
  // TODO: Put this in mountModel.  Had trouble accessing viewOptions from mountModel.
  // It's also used by HardwareView, so duplicated for now.
  func pointingKnowledgeColor() -> Color {
    switch (mountModel.pointingKnowledge)
    {
      case .none:
        return viewOptions.confNoneColor
      case .estimated:
        return viewOptions.confEstColor
      case .marked:
        return viewOptions.appRedColor
    }
  }
  
  var body: some View {
    
    VStack {

      if !mountModel.bleConnected() {
        TabTitleView(label: mountModel.statusString,
                       mountModel: mountModel)
      } else {
        let stateEnum = MountState(rawValue: gdb.mountState)
        TabTitleView(label: String("\(stateEnum ?? MountState.StateError)"),
                       mountModel: mountModel)
      }
      
      NavigationView {
        
        VStack{
          RaDecPairView(
            pairTitle: "Current\nPosition",
            pair: mountModel.currentPosition,
            pierDeg: mountModel.pierCurrentDeg,
            diskDeg: mountModel.diskCurrentDeg,
            lstDeg: mountModel.lstDeg)
          .foregroundColor(pointingKnowledgeColor())
          .padding([.bottom], 1)

            NavigationLink {
              RaDecInputView(label: "Select Reference",
                             coord: $mountModel.refCoord,
                             name: $mountModel.refName,
                             catalog: mountModel.catalog,
                             lstDeg: mountModel.lstDeg)
            } label: {
              let (refPierDeg, refDiskDeg, _) = mountModel.raDecToMountAngles( mountModel.refCoord, lst: mountModel.lstDeg)
              RaDecPairView(pairTitle: "Reference:\n\(mountModel.refName)",
                            pair: mountModel.refCoord,
                            pierDeg: refPierDeg,
                            diskDeg: refDiskDeg,
                            lstDeg: mountModel.lstDeg)
              .foregroundColor(viewOptions.appActionColor)
            }
            
            NavigationLink {
              RaDecInputView(label: "Select Target",
                             coord: $mountModel.targetCoord,
                             name: $mountModel.targName,
                             catalog: mountModel.catalog,
                             lstDeg: mountModel.lstDeg)
              
            } label: {
              let (targetPierDeg, targetDiskDeg, _) =  mountModel.raDecToMountAngles(
                mountModel.targetCoord, lst: mountModel.lstDeg)
              RaDecPairView(pairTitle: "Target:\n\(mountModel.targName)",
                            pair: mountModel.targetCoord,
                            pierDeg: targetPierDeg,
                            diskDeg: targetDiskDeg,
                            lstDeg: mountModel.lstDeg)
              .foregroundColor(viewOptions.appActionColor)
            }
            
            MountChangeView(title: "Angles to Target",
                            pierMoveDeg: mountModel.anglesCurrentToTarget().ra,
                            diskMoveDeg: mountModel.anglesCurrentToTarget().dec)

          Divider()

          // Big Button Area
          VStack {
            Spacer()
            
            HStack {
              Spacer()
              BigButton(label:"Swap") {
                mountModel.swapRefAndTarg()
              }
              Spacer()
              BigButton(label:"Mark\nTarget") {
                mountModel.guideCommandMarkTarget()
                heavyBump()
              }
              Spacer()
            }
            
            Spacer()

            BigButton(label: "GoTo Target") {
                mountModel.guideCommandGoToTarget()
                heavyBump()
            }

            Spacer()

            StopControlView(mountModel: mountModel)
          }
          
        } // VStack in NavigationView
        .navigationBarTitle("") // needed for navigationBarHidden to work.
        .navigationBarHidden(true)
        
      } // NavigationView
      
    } // Top Level VStack
    .onAppear{
      softBump()
    } // body: some View
  }
  

}

struct GuideView_Previews: PreviewProvider {
  static let viewOptions = ViewOptions()
  static let previewGuideModel = MountBleModel()
  static var previews: some View {
    GuideView(mountModel: previewGuideModel)
      .environmentObject(viewOptions)
      .preferredColorScheme(.dark)
      .foregroundColor(viewOptions.appRedColor)
  }
}
