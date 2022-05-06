//
//  guideView.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/27/22.
//

import SwiftUI

struct GuideView: View {
  
  // App level options into Environment
  @StateObject private var appOptions = AppOptions()
  
  // Model at App scope.  Pass to Views as needed.
  @StateObject private var guideModel = GuideModel()
  
  @EnvironmentObject var viewOptions: ViewOptions
  
  var gdb:GuideDataBlock {
    guideModel.guideDataBlock
  }
  
  var mountStateString:String {
    let stateEnum = MountState(rawValue: gdb.mountState)
    let stateString:String = "\(stateEnum ?? MountState.StateError)"
    return(stateString)
  }
  
  @State var useDirectOffset = false
  @State var directOffset = RaDec(ra: 0.0, dec: 0.0)
  @State var junk = true
  
  var body: some View {
    
    VStack {
      
      VStack {
        HStack{
          if !guideModel.bleConnected {
            Text("Status: ")
            Text(guideModel.statusString)
          } else {
            Text("EqMount: ")
            let stateEnum = MountState(rawValue: gdb.mountState)
            Text(String("\(stateEnum ?? MountState.StateError)"))
          }
        }.font(.title)
        HStack {
          if (appOptions.showDmsHms) {
            let hms = Hms(deg: guideModel.lstDeg)
            let dmsString = String(format: "LST: %02dh %02dm %02ds",
                                   hms.h, hms.m, hms.s)
            Text(dmsString)
              .foregroundColor(lstValidColor())
          } else {
            AngleDegView(label: "LST: ",
                         angleDeg: guideModel.lstDeg)
            .foregroundColor(lstValidColor())
          }
          Spacer()
          Button() {
            appOptions.showDmsHms = !appOptions.showDmsHms
          } label: {
            Text(appOptions.showDmsHms ? "Show Degrees" : "Show DMS/HMS")
          }
        }
      }
      Divider()
      
      NavigationView {
        
        VStack{
          RaDecPairView(
            pairTitle: "Current Position",
            pair: guideModel.currentPosition)
          .foregroundColor(pointingKnowledgeColor())
          
          AngleDegView(label: "Arm: ",
                       angleDeg: guideModel.armCurrentDeg)
          .foregroundColor(pointingKnowledgeColor())
          
          Divider()
          
          Picker(selection: $useDirectOffset,
                 label: Text("???")) {
            Text("Offset").tag(true)
            Text("Ref/Targ").tag(false)
          }
                 .pickerStyle(.segmented)
                 .padding([.leading, .trailing], 10)
          
          
          if !useDirectOffset {
            NavigationLink {
              RaDecInputView(label: "Enter Reference Coordinates",
                             coord: $guideModel.refCoord,
                             unitHmsDms: $appOptions.showDmsHms,
                             catalog: guideModel.catalog)
            } label: {
              RaDecPairView(pairTitle: "Reference Coordinates",
                            pair: guideModel.refCoord)
              .foregroundColor(viewOptions.appActionColor)
            }
            
            NavigationLink {
              RaDecInputView(label: "Enter Target Coordinates",
                             coord: $guideModel.targetCoord,
                             unitHmsDms: $appOptions.showDmsHms,
                             catalog: guideModel.catalog)
              
            } label: {
              RaDecPairView(pairTitle: "Target Coordinates",
                            pair: guideModel.targetCoord)
              .foregroundColor(viewOptions.appActionColor)
            }
            
            RaDecPairView(pairTitle: "Offset to Target",
                          pair: RaDec(ra: guideModel.armDeltaDeg(),
                                      dec:guideModel.diskDeltaDeg()))
            
          } else {
            NavigationLink {
              RaDecInputView(label: "Enter Direct Offset",
                             coord: $directOffset,
                             unitHmsDms: $appOptions.showDmsHms,
                             catalog: guideModel.catalog)
              
            } label: {
              RaDecPairView(pairTitle: "Direct Offset",
                            pair: directOffset)
              .foregroundColor(viewOptions.appActionColor)
            }
          }
          
          Divider()
          
          Spacer()
          
          HStack {
            BigButton(label:"Swap") {
              let temp = guideModel.refCoord
              guideModel.refCoord = guideModel.targetCoord
              guideModel.targetCoord = temp
            }
            if useDirectOffset {
              BigButton(label:" Set Offset  ") {
                // TODO - build arm and disk deltas in a guideModel func
                // With LST and estimate of current RA, can build proper deltas.
                // Otherwise, just make them proportional -- color yellow.
                guideModel.offsetRaDec(gdb: guideModel.guideDataBlock,
                                       armDeltaDeg:  directOffset.ra,
                                       diskDeltaDeg: directOffset.dec)
                heavyBump()
              }
            } else {
              BigButton(label:" Set Target  ") {
                guideModel.targetRaDec(gdb: guideModel.guideDataBlock,
                                       armDeltaDeg: guideModel.armDeltaDeg(),
                                       diskDeltaDeg: guideModel.diskDeltaDeg())
                heavyBump()
              }
            }
          }
          
          RawDataView(gdb: gdb)
            .foregroundColor((guideModel.bleConnected ? viewOptions.appRedColor : viewOptions.appDisabledColor) )
        } // VStack in NavigationView
        .navigationBarTitle("") // needed for navigationBarHidden to work.
        .navigationBarHidden(true)
        
      } // NavigationView
      
    } // Top Level VStack
    .onAppear{
      guideModel.guideModelInit()
      setupSegmentControl()
      softBump()
    } // body: some View
  }
  
  func pointingKnowledgeColor() -> Color {
    switch (guideModel.pointingKnowledge)
    {
      case .none:
        return viewOptions.confNoneColor
      case .estimated:
        return viewOptions.confEstColor
      case .marked:
        return viewOptions.appRedColor
    }
  }
  
  func lstValidColor() -> Color {
    return guideModel.lstValid ? viewOptions.appRedColor : viewOptions.confNoneColor
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
  static var previews: some View {
    GuideView()
      .environmentObject(viewOptions)
      .preferredColorScheme(.dark)
      .foregroundColor(viewOptions.appRedColor)
  }
}
