//
//  guideView.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/27/22.
//

import SwiftUI

struct GuideView: View {
  
  @EnvironmentObject var guideModel:GuideModel
  
  var gdb:GuideDataBlock {
    guideModel.guideDataBlock
  }
  
  let armAngle:Float = 45.0 // future gdb value from mount
  
  var body: some View {
    
    NavigationView{
      
      VStack {
        HStack{
          Text("Status: ")
          Text(guideModel.statusString)
        }.font(.title)
        
        VStack{
          RaDecPairView(
            pairTitle: "Current Position",
            pair: RaDec(ra: Float32(gdb.raCount) * gdb.raDegPerStep,
                        dec: Float32(gdb.decCount) * gdb.decDegPerStep) )
          ArmAngleView(angleDeg: armAngle)

          NavigationLink {
            RaDecInputView(label: "Enter Reference Coordinates",
                           coord: guideModel.refCoord)
          } label: {
            RaDecPairView(pairTitle: "Reference Coordinates",
                          pair: guideModel.refCoord)
          }

          NavigationLink {
            RaDecInputView(label: "Enter Target Coordinates",
                           coord: guideModel.targetCoord)
          } label: {
            RaDecPairView(pairTitle: "Target Coordinates",
                          pair: guideModel.targetCoord)
          }

          RaDecPairView(pairTitle: "Offset to Target",
                        pair: guideModel.targetCoord - guideModel.refCoord)
        }
        
        Spacer()
        
        BigButton(label:" Update Mount ") {
          guideModel.offsetRaDec(raOffsetDeg: 0.0, decOffsetDeg: 10.0)
        }
        
        Spacer()
        
        RawDataView(gdb: gdb)
      } // Top Level VStack
      .onAppear{
        guideModel.guideModelInit()
      }
    } // NavigationView
  }
}

struct GuideView_Previews: PreviewProvider {
  static var previews: some View {
    GuideView()
      .environmentObject(GuideModel())
  }
}