//
//  guideView.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/27/22.
//

import SwiftUI

struct GuideView: View {
  
  @ObservedObject var guideModel:GuideModel
  
  var gdb:GuideDataBlock {
    guideModel.guideDataBlock
  }
  
  var mountStateString:String {
    let stateEnum = MountState(rawValue: gdb.mountState)
    let stateString:String = "\(stateEnum ?? MountState.StateError)"
    return(stateString)
  }
  
  let armAngle:Float = 45.0 // future gdb value from mount
  
  @State var useDirectOffset = false
  @State var directOffset = RaDec(ra: 0.0, dec: 0.0)
  
  var body: some View {
    
    VStack {
      
      HStack{
        Text("Status: ")
        let statusString =  guideModel.statusString
        if statusString != "Connected" {
          Text(statusString)
        } else {
          let stateEnum = MountState(rawValue: gdb.mountState)
          Text(String("\(stateEnum ?? MountState.StateError)"))
        }
      }.font(.title)
      Divider()
      
      NavigationView {
        
        VStack{
          RaDecPairView(
            pairTitle: "Current Position",
            pair: RaDec(ra: Float32(gdb.raCount) * gdb.raDegPerStep,
                        dec: Float32(gdb.decCount) * gdb.decDegPerStep) )

          ArmAngleView(angleDeg: armAngle)

          Divider()

          Picker(selection: $useDirectOffset,
                 label: Text("???")) {
            Text("Offset").tag(true)
            Text("Ref/Targ").tag(false)
          }
//          .onChange(of: useDirectOffset) {softBump()}
          .pickerStyle(.segmented)
          .padding([.leading, .trailing], 10)

          
          if !useDirectOffset {
            NavigationLink {
              RaDecInputView(label: "Enter Reference Coordinates",
                             coord: $guideModel.refCoord)
            } label: {
              RaDecPairView(pairTitle: "Reference Coordinates",
                            pair: guideModel.refCoord)
            }
            
            NavigationLink {
              RaDecInputView(label: "Enter Target Coordinates",
                             coord: $guideModel.targetCoord)
            } label: {
              RaDecPairView(pairTitle: "Target Coordinates",
                            pair: guideModel.targetCoord)
            }
            
            RaDecPairView(pairTitle: "Offset to Target",
                          pair: guideModel.offset)
            
          } else {
            NavigationLink {
              RaDecInputView(label: "Enter Direct Offset",
                             coord: $directOffset)
            } label: {
              RaDecPairView(pairTitle: "Direct Offset",
                            pair: directOffset)
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
            .foregroundColor((guideModel.statusString == "Connected" ? .black : .gray))
        } // VStack in NavigationView
        .navigationBarTitle("") // needed for navigationBarHidden to work.
        .navigationBarHidden(true)
   
      } // NavigationView
      
    } // Top Level VStack
    .onAppear{
      guideModel.guideModelInit()
      
      //this changes the "thumb" that selects between items
//      UISegmentedControl.appearance().selectedSegmentTintColor = .white
      //and this changes the color for the whole "bar" background
//      UISegmentedControl.appearance().backgroundColor = UIColor(red:0.9, green:0.9, blue:0.9, alpha: 1.0)

      //this will change the font size
      UISegmentedControl.appearance().setTitleTextAttributes([.font : UIFont.preferredFont(forTextStyle: .title2)], for: .normal)

      //these lines change the text color for various states
//      UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor : UIColor.blue], for: .selected)
//      UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor : UIColor.blue], for: .normal)

    } // body: some View
  }

  func heavyBump(){
    let haptic = UIImpactFeedbackGenerator(style: .heavy)
    haptic.impactOccurred()
  }
  
  func softBump(){
    let haptic = UIImpactFeedbackGenerator(style: .soft)
    haptic.impactOccurred()
  }

}

struct GuideView_Previews: PreviewProvider {
  static var previews: some View {
    GuideView(guideModel: GuideModel())
  }
}
