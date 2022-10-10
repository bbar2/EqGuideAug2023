//
//  guideView.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/27/22.
//

import SwiftUI

struct GuideView: View {
  @ObservedObject var guideModel: GuideModel
    
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
            pair: guideModel.currentPosition,
            showDmsHms: viewOptions.showDmsHms,
            armDeg: guideModel.armCurrentDeg,
            dskDeg: guideModel.dskCurrentDeg
          )
          .foregroundColor(pointingKnowledgeColor())
          .padding([.bottom], 1)

          HStack {
            Text("LST: " + Hms(guideModel.lstDeg).string(viewOptions.showDmsHms))
              .foregroundColor(lstValidColor())
            Spacer()
            let latString = Dms(guideModel.locationData.latitudeDeg ?? 0).string(viewOptions.showDmsHms)
            Text("Lat:" + latString).foregroundColor(lstValidColor())
            Spacer()
            let longString = Dms(guideModel.locationData.longitudeDeg ?? 0).string(viewOptions.showDmsHms)
            Text("Lng:" + longString).foregroundColor(lstValidColor())
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
                             unitHmsDms: viewOptions.showDmsHms,
                             catalog: guideModel.catalog)
            } label: {
              let (refArmDeg, refDskDeg) = guideModel.mountAnglesForRaDec( guideModel.refCoord)
              RaDecPairView(pairTitle: "Reference:\n\(guideModel.refName)",
                            pair: guideModel.refCoord,
                            showDmsHms: viewOptions.showDmsHms,
                            armDeg: refArmDeg,
                            dskDeg: refDskDeg)
              .foregroundColor(viewOptions.appActionColor)
            }
            
            NavigationLink {
              RaDecInputView(label: "Select Target",
                             coord: $guideModel.targetCoord,
                             name: $guideModel.targName,
                             unitHmsDms: viewOptions.showDmsHms,
                             catalog: guideModel.catalog)
              
            } label: {
              let (targetArmDeg, targetDskDeg) = guideModel.mountAnglesForRaDec(guideModel.targetCoord)
              RaDecPairView(pairTitle: "Target:\n\(guideModel.targName)",
                            pair: guideModel.targetCoord,
                            showDmsHms: viewOptions.showDmsHms,
                            armDeg: targetArmDeg,
                            dskDeg: targetDskDeg)
              .foregroundColor(viewOptions.appActionColor)
            }
            
            MountChangeView(title: "Mount Movement:\nRef to Target",
                            armMoveDeg: guideModel.anglesReferenceToTarget().ra,
                            dskMoveDeg: guideModel.anglesReferenceToTarget().dec)
            

          } else {  // start from current
            NavigationLink {
              RaDecInputView(label: "Select Target",
                             coord: $guideModel.targetCoord,
                             name: $guideModel.targName,
                             unitHmsDms: viewOptions.showDmsHms,
                             catalog: guideModel.catalog)
              
            } label: {
              let (targetArmDeg, targetDskDeg) = guideModel.mountAnglesForRaDec(guideModel.targetCoord)
              RaDecPairView(pairTitle: "Target:\n\(guideModel.targName)",
                            pair: guideModel.targetCoord,
                            showDmsHms: viewOptions.showDmsHms,
                            armDeg: targetArmDeg,
                            dskDeg: targetDskDeg)
              .foregroundColor(viewOptions.appActionColor)
            }
            
            MountChangeView(title: "Mount Movement:\nCurrent to Target",
                            armMoveDeg: guideModel.anglesCurrentToTarget().ra,
                            dskMoveDeg: guideModel.anglesCurrentToTarget().dec)

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
