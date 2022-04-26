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
  
  var body: some View {
    
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
      Divider()
      
      NavigationView {
        
        VStack{
          RaDecPairView(
            pairTitle: "Current Position",
            pair: guideModel.currentPosition )
          
          ArmAngleView(angleDeg: guideModel.armCurrentDeg)
          
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
                             editInFloat: $appOptions.editInFloat)
            } label: {
              ZStack {
                // works well but causes sizing issues in OFFSET mode
//                RoundedRectangle(cornerRadius: CGFloat(30), style: .circular)
//                  .fill(viewOptions.thumbColor)
//                  .padding([.top],20)
                RaDecPairView(pairTitle: "Reference Coordinates",
                              pair: guideModel.refCoord)
                .foregroundColor(viewOptions.appActionColor)

              }
            }
            
            NavigationLink {
              RaDecInputView(label: "Enter Target Coordinates",
                             coord: $guideModel.targetCoord,
                             editInFloat: $appOptions.editInFloat)

            } label: {
              ZStack {
//                RoundedRectangle(cornerRadius: CGFloat(30), style: .circular)
//                  .fill(viewOptions.thumbColor)
//                  .padding([.top],20)
                RaDecPairView(pairTitle: "Target Coordinates",
                              pair: guideModel.targetCoord)
                .foregroundColor(viewOptions.appActionColor)

              }
            }
            
            RaDecPairView(pairTitle: "Offset to Target",
                          pair: guideModel.offset)
            
          } else {
            NavigationLink {
              RaDecInputView(label: "Enter Direct Offset",
                             coord: $directOffset,
                             editInFloat: $appOptions.editInFloat)
            } label: {
              ZStack {
//                RoundedRectangle(cornerRadius: CGFloat(30), style: .circular)
//                  .fill(viewOptions.thumbColor)
//                  .padding([.top],20)
                RaDecPairView(pairTitle: "Direct Offset",
                              pair: directOffset)
                .foregroundColor(viewOptions.appActionColor)
              }
            }
          }
          
          Divider()
          
          Spacer()
          
          if useDirectOffset {
            BigButton(label:" Set Offset  ") {
              guideModel.offsetRaDec(coord: directOffset)
              heavyBump()
            }
          } else {
            BigButton(label:" Set Target  ") {
              guideModel.targetRaDec(coord: guideModel.offset)
              heavyBump()
            }
          }
          
          RawDataView(gdb: gdb)
            .foregroundColor((guideModel.bleConnected ? viewOptions.appRedColor : .gray) )
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
