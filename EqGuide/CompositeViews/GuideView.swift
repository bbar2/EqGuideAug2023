//
//  guideView.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/27/22.
//

import SwiftUI

struct GuideView: View {
  
  @EnvironmentObject var guideModel:GuideModel
  
  @State private var refCoord = RaDec(ra:97.5, dec:0.0)
  @State private var targetCoord = RaDec()
  
  var gdb:GuideDataBlock {
    return guideModel.guideDataBlock
  }
  
  let armAngle:Float = 45.0
  
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
                           coord: $refCoord)
          } label: {
            RaDecPairView(pairTitle: "Reference Coordinates",
                          pair: refCoord)
          }
          NavigationLink {
            RaDecInputView(label: "Enter Target Coordinates",
                           coord: $targetCoord)
          } label: {
            RaDecPairView(pairTitle: "Target Coordinates",
                          pair: targetCoord)
          }
          RaDecPairView(pairTitle: "Offset to Target",
                        pair: targetCoord - refCoord)
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
