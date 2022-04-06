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
  
  let armAngle:Float = 45.0 // future gdb value from mount
  
  @State var useDirectOffset = false
  @State var directOffset = RaDec(ra: 0.0, dec: 0.0)
  
  var body: some View {
    
    VStack {
      
      HStack{
        Text("Status: ")
        Text(guideModel.statusString)
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

          Toggle("Use Direct Offset", isOn: $useDirectOffset)

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
          
          Spacer()
          
          if useDirectOffset {
            BigButton(label:" Set Offset  ") {
              guideModel.offsetRaDec(coord: directOffset)
              heavyBump()
            }
          } else {
            BigButton(label:" Set Target  ") {
              guideModel.offsetRaDec(coord: guideModel.offset)
              heavyBump()
            }
          }
          
          RawDataView(gdb: gdb)
        } // VStack in NavigationView
        .navigationBarTitle("")
        .navigationBarHidden(true)
   
      } // NavigationView
      
    } // Top Level VStack
    .onAppear{
      guideModel.guideModelInit()
      
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
