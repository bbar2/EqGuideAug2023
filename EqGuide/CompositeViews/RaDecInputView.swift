//
//  RaInputView.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/27/22.
//

import SwiftUI

struct RaDecInputView: View {
  
  var label:String
  @Binding var coord: RaDec
  @Binding var unitHmsDms: Bool
  var catalog : [Target]

  @EnvironmentObject var viewOptions: ViewOptions
  @Environment(\.dismiss) private var dismissView

//  @State private var tempRaDec = RaDec()
  @State private var tempRa = Double(0)
  @State private var tempDec = Double(0)
  @State private var targetName = "Manual Entry"

  var body: some View {
    
    VStack {
      HStack{
        Button{
          softBump()
          dismissView()
        } label: {
          Text("< Cancel")
            .font(.title3).bold()
            .foregroundColor(viewOptions.appActionColor)
        }
        Spacer()
      }.padding([.bottom], 20)

      VStack {
        Text(label)
        Text(targetName)
      }
      .font(.title)
      .padding([.top], 20)

      VStack {
        if unitHmsDms {
          HmsInputView(decimalDegrees: $tempRa, prefix: "RA")
          DmsInputView(decimalDegrees: $tempDec, prefix: "DEC")
        } else {
          FloatInputView(doubleValue: $tempRa, prefix: "RA")
          FloatInputView(doubleValue: $tempDec, prefix: "DEC")
        }
      }
      .onAppear() {
        tempRa = coord.ra
        tempDec = coord.dec
      }
      
      BigButton(label:"Apply") {
        coord.ra = tempRa
        coord.dec = tempDec
        heavyBump()
        dismissView()
      }
      
      TargetListView(catalog: catalog, targetTapAction: makeTargetCurrent)
    }
    .navigationBarBackButtonHidden(true)
    .navigationBarTitle("") // needed for navigationBarHidden to work.
    .navigationBarHidden(true)

    .onAppear() {
      softBump()
    }
  }

  func makeTargetCurrent(tappedTarget: Target) {
    tempRa  = tappedTarget.ra
    tempDec = tappedTarget.dec
    targetName = tappedTarget.name
    softBump()
  }

}

struct RaInputView_Previews: PreviewProvider {
  @State static var testCoord = RaDec(ra: 97.5, dec: 0.25)
  @State static var viewOptions = ViewOptions()
  @State static var useHmsDms = true
  @State static var guideModel = GuideModel()
  
  static var previews: some View {
    RaDecInputView(label: "Enter RA/DEC Pair",
                   coord: $testCoord,
                   unitHmsDms: $useHmsDms,
                   catalog: guideModel.catalog)
      .environmentObject(viewOptions)
      .preferredColorScheme(.dark)
      .foregroundColor(viewOptions.appRedColor)
  }
}

