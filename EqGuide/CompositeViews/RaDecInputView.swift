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
  @Binding var editInFloat: Bool
  var catalog : [Target]

  @EnvironmentObject var viewOptions: ViewOptions

  @State private var tempRaDec = RaDec()
  @State private var targetName = "Manual Entry"
  @Environment(\.dismiss) private var dismissView
  
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
        if editInFloat {
          FloatInputView(doubleValue: $tempRaDec.ra, prefix: "RA")
          FloatInputView(doubleValue: $tempRaDec.dec, prefix: "DEC")
        } else {
          HmsInputView(decimalDegrees: $tempRaDec.ra, prefix: "RA")
          DmsInputView(decimalDegrees: $tempRaDec.dec, prefix: "DEC")
        }
      }
      Button() {
        editInFloat = !editInFloat
        softBump()
      } label: {
        Text(editInFloat ? "Switch to HMS/DMS" : "Switch To Decimal Degrees")
          .font(.title2)
          .bold()
      }
      .onAppear() {
        tempRaDec = coord
      }
      
      BigButton(label:"Apply") {
        coord  = tempRaDec
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

  func makeTargetCurrent(newTarget: Target) {
    tempRaDec.ra = newTarget.ra
    tempRaDec.dec = newTarget.dec
    targetName = newTarget.name
    softBump()
  }

}

struct RaInputView_Previews: PreviewProvider {
  @State static var testCoord = RaDec(ra: 97.5, dec: 0.25)
  @State static var viewOptions = ViewOptions()
  @State static var editInFloat = true
  @State static var guideModel = GuideModel()
  
  static var previews: some View {
    RaDecInputView(label: "Enter RA/DEC Pair",
                   coord: $testCoord,
                   editInFloat: $editInFloat,
                   catalog: guideModel.catalog)
      .environmentObject(viewOptions)
      .preferredColorScheme(.dark)
      .foregroundColor(viewOptions.appRedColor)
  }
}

