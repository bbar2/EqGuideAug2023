//
//  guideView.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/27/22.
//

import SwiftUI

struct GuideView: View {

  @ObservedObject var guideModel:GuideModel
  @State private var refCoord = RaDec(ra:97.5, dec:0.0)
  @State private var targetCoord = RaDec()

  var gdb:GuideDataBlock {
    return guideModel.guideDataBlock
  }

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
            NavigationLink {
              RaInputView(label: "Enter New\nReference Coordinates",
                          coord: $refCoord)
            } label: {
              RaDecPairView(pairTitle: "Reference Coordinates",
                            pair: refCoord)
            }
            NavigationLink {
              RaInputView(label: "Enter New\nTarget Coordinates",
                          coord: $targetCoord)
            } label: {
              RaDecPairView(pairTitle: "Target Coordinates",
                            pair: targetCoord)
            }
          }
          
          Spacer()
          
          HStack{
            Spacer()
            Button("Add 10 Deg Dec") {
              guideModel.offsetRaDec(raOffsetDeg: 0.0, decOffsetDeg: 10.0)
            }
            Spacer()
            Button("Sub 10 Deg Dec") {
              guideModel.offsetRaDec(raOffsetDeg: 0.0, decOffsetDeg: -10.0)
            }
            Spacer()
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
      GuideView(guideModel: GuideModel())
    }
}
