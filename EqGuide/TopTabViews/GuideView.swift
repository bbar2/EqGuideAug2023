//
//  guideView.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/27/22.
//

import SwiftUI

struct GuideView: View {
  @ObservedObject var guideModel: GuideModel

  // App level options into Environment
  @StateObject private var appOptions = AppOptions()
    
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
            Text(appOptions.showDmsHms ? "DMS/HMS" : "Degrees")
              .foregroundColor(viewOptions.appActionColor).bold()
          }
        }
      }
      
      NavigationView {
        
        VStack{
          RaDecPairView(
            pairTitle: "Current Position",
            pair: guideModel.currentPosition,
            unitHmsDms: appOptions.showDmsHms)
          .foregroundColor(pointingKnowledgeColor())

          Divider()

          HStack {
            let armString = "Arm: " + Hms(guideModel.armCurrentDeg).string(false)
            Text(armString).foregroundColor(pointingKnowledgeColor())
            Spacer()
            let latString = Dms(guideModel.locationData.latitudeDeg ?? 0).string(appOptions.showDmsHms)
            Text("Lat:" + latString).foregroundColor(lstValidColor())
            Spacer()
            let longString = Dms(guideModel.locationData.longitudeDeg ?? 0).string(appOptions.showDmsHms)
            Text("Long:" + longString).foregroundColor(lstValidColor())
          }.font(viewOptions.smallValueFont)
          
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
              RaDecPairView(pairTitle: "Reference:\n\(guideModel.refName)",
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
              RaDecPairView(pairTitle: "Target:\n\(guideModel.targName)",
                            pair: guideModel.targetCoord,
                            unitHmsDms: appOptions.showDmsHms)
              .foregroundColor(viewOptions.appActionColor)
            }
            
            RaDecPairView(pairTitle: "Mount Angles:\nRef to Target",
                          pair: guideModel.anglesReferenceToTarget(),
                          unitHmsDms: false,
                          labelRa: "RA Arm",
                          labelDec: "Dec Axis")

          } else {
            NavigationLink {
              RaDecInputView(label: "Select Target",
                             coord: $guideModel.targetCoord,
                             name: $guideModel.targName,
                             unitHmsDms: appOptions.showDmsHms,
                             catalog: guideModel.catalog)
              
            } label: {
              RaDecPairView(pairTitle: "Target:\n\(guideModel.targName)",
                            pair: guideModel.targetCoord,
                            unitHmsDms: appOptions.showDmsHms)
              .foregroundColor(viewOptions.appActionColor)
            }
            
            RaDecPairView(pairTitle: "Mount Angles:\nCurrent to Target",
                          pair: guideModel.anglesCurrentToTarget(),
                          unitHmsDms: false,
                          labelRa: "RA Arm",
                          labelDec: "Dec Axis")

          }
          
          Divider()

          // Big Button Area
          VStack {
            Spacer()
            
            HStack {
              Spacer()
              BigButton(label:"Swap") {
                guideModel.swapRefAndTarg()
              }
              Spacer()
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
              Spacer()
            }
            
            Spacer()
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
  static let guideModel = GuideModel()
  static var previews: some View {
    GuideView(guideModel: guideModel)
      .environmentObject(viewOptions)
      .preferredColorScheme(.dark)
      .foregroundColor(viewOptions.appRedColor)
  }
}
