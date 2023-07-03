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
  
  var gdb:GuideDataBlock {
    mountModel.guideDataBlock
  }
  
  var mountStateString:String {
    let stateEnum = MountState(rawValue: gdb.mountState)
    let stateString:String = "\(stateEnum ?? MountState.StateError)"
    return(stateString)
  }
  
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
      
      VStack {
        HStack{
          if !mountModel.bleConnected() {
            Text(mountModel.statusString)
          } else {
            let stateEnum = MountState(rawValue: gdb.mountState)
            Text(String("\(stateEnum ?? MountState.StateError)"))
          }
        }.font(.title)
        HStack {
          BleStatusView(mountModel: mountModel)
          //, focusModel: focusModel, pierModel: pierModel)
          Spacer()
          Button() {
            viewOptions.showDmsHms = !viewOptions.showDmsHms
          } label: {
            Text(viewOptions.showDmsHms ? "DMS/HMS" : "Degrees")
              .foregroundColor(viewOptions.appActionColor).bold()
          }
        }
      }
      
      NavigationView {
        
        VStack{
          RaDecPairView(
            pairTitle: "Current\nPosition",
            pair: mountModel.currentPosition,
            showDmsHms: viewOptions.showDmsHms,
            pierDeg: mountModel.pierCurrentDeg,
            diskDeg: mountModel.diskCurrentDeg
          )
          .foregroundColor(pointingKnowledgeColor())
          .padding([.bottom], 1)

            NavigationLink {
              RaDecInputView(label: "Select Reference",
                             coord: $mountModel.refCoord,
                             name: $mountModel.refName,
                             unitHmsDms: viewOptions.showDmsHms,
                             catalog: mountModel.catalog)
            } label: {
              let (refPierDeg, refDiskDeg) = mountModel.raDecToMountAngles( mountModel.refCoord)
              RaDecPairView(pairTitle: "Reference:\n\(mountModel.refName)",
                            pair: mountModel.refCoord,
                            showDmsHms: viewOptions.showDmsHms,
                            pierDeg: refPierDeg,
                            diskDeg: refDiskDeg)
              .foregroundColor(viewOptions.appActionColor)
            }
            
            NavigationLink {
              RaDecInputView(label: "Select Target",
                             coord: $mountModel.targetCoord,
                             name: $mountModel.targName,
                             unitHmsDms: viewOptions.showDmsHms,
                             catalog: mountModel.catalog)
              
            } label: {
              let (targetPierDeg, targetDiskDeg) = mountModel.raDecToMountAngles(mountModel.targetCoord)
              RaDecPairView(pairTitle: "Target:\n\(mountModel.targName)",
                            pair: mountModel.targetCoord,
                            showDmsHms: viewOptions.showDmsHms,
                            pierDeg: targetPierDeg,
                            diskDeg: targetDiskDeg)
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

            BigButton(label: " GoTo Target ") {
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
      setupSegmentControl()
      softBump()
    } // body: some View
  }
  
  func lstValidColor() -> Color {
    return mountModel.lstValid ? viewOptions.appRedColor : viewOptions.confNoneColor
  }
  
  func setupSegmentControl() {
    // Set color of "thumb" that selects between items
    UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(viewOptions.thumbColor)
    
    // Set color for whole "bar" background
    UISegmentedControl.appearance().backgroundColor = UIColor(viewOptions.thumbBarColor)
    
    // Set font attributes - call once for each state (.normal, .selected)
    UISegmentedControl.appearance().setTitleTextAttributes(
      [.font : UIFont.preferredFont(forTextStyle: .title2),
       .foregroundColor : UIColor(viewOptions.appActionColor)], for: .normal)
    
    UISegmentedControl.appearance().setTitleTextAttributes(
      [.foregroundColor : UIColor(viewOptions.appActionColor),
       .font : UIFont.preferredFont(forTextStyle: .title2)], for: .selected)
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
