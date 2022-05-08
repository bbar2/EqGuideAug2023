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
  
  @State var startFromReference = true
  
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
          Text("LST: " + Hms(guideModel.lstDeg).string(appOptions.showDmsHms))
            .foregroundColor(lstValidColor())
          Spacer()
          Button() {
            appOptions.showDmsHms = !appOptions.showDmsHms
          } label: {
            Text(appOptions.showDmsHms ? "Show Decimal Degrees" : "Show DMS/HMS")
          }
        }
      }
      Divider()
      
      NavigationView {
        
        VStack{
          RaDecPairView(
            pairTitle: "Current Position",
            pair: guideModel.currentPosition,
            unitHmsDms: appOptions.showDmsHms)
          .foregroundColor(pointingKnowledgeColor())
          
          Text("Arm: " + Hms(guideModel.armCurrentDeg).string(false))
            .foregroundColor(pointingKnowledgeColor())
          
          Divider()
          
          Picker(selection: $startFromReference,
                 label: Text("???")) {
            Text("Ref/Targ").tag(true)
            Text("Targ").tag(false)
          }
                 .pickerStyle(.segmented)
                 .padding([.leading, .trailing], 10)
          
          
          if startFromReference {
            NavigationLink {
              RaDecInputView(label: "Select Reference",
                             coord: $guideModel.refCoord,
                             name: $guideModel.refName,
                             unitHmsDms: appOptions.showDmsHms,
                             catalog: guideModel.catalog)
            } label: {
              RaDecPairView(pairTitle: "Reference: \(guideModel.refName)",
                            pair: guideModel.refCoord,
                            unitHmsDms: appOptions.showDmsHms)
              .foregroundColor(viewOptions.appActionColor)
            }
            
            NavigationLink {
              RaDecInputView(label: "Select Target",
                             coord: $guideModel.targetCoord,
                             name: $guideModel.targName,
                             unitHmsDms: appOptions.showDmsHms,
                             catalog: guideModel.catalog)
              
            } label: {
              RaDecPairView(pairTitle: "Target: \(guideModel.targName)",
                            pair: guideModel.targetCoord,
                            unitHmsDms: appOptions.showDmsHms)
              .foregroundColor(viewOptions.appActionColor)
            }
            
            RaDecPairView(pairTitle: "Angles Ref to Target",
                          pair: guideModel.anglesReferenceToTarget(),
                          unitHmsDms: false,
                          labelRa: "Arm",
                          labelDec: "Axis")

          } else {
            NavigationLink {
              RaDecInputView(label: "Select Target",
                             coord: $guideModel.targetCoord,
                             name: $guideModel.targName,
                             unitHmsDms: appOptions.showDmsHms,
                             catalog: guideModel.catalog)
              
            } label: {
              RaDecPairView(pairTitle: "Target: \(guideModel.targName)",
                            pair: guideModel.targetCoord,
                            unitHmsDms: appOptions.showDmsHms)
              .foregroundColor(viewOptions.appActionColor)
            }
            
            RaDecPairView(pairTitle: "Angles Current to Target",
                          pair: guideModel.anglesCurrentToTarget(),
                          unitHmsDms: false,
                          labelRa: "Arm",
                          labelDec: "Axis")

          }
          
          Divider()
          
          Spacer()
          
          HStack {
            BigButton(label:"Swap") {
              guideModel.swapRefAndTarg()
            }
            if startFromReference {
              BigButton(label:" Set Target  \n & Ref") {
                guideModel.guideCommandReferenceToTarget()
                heavyBump()
              }
            } else {
              BigButton(label:" Set Target  ") {
                guideModel.guideCommandCurrentToTarget()
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
