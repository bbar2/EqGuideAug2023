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
  @Binding var name: String
  var unitHmsDms: Bool
  var catalog : [Target]

  @EnvironmentObject var viewOptions: ViewOptions
  @Environment(\.dismiss) private var dismissView

  @State private var tempCoord = RaDec()
  @State private var tempName = "Manual Entry"
  //ToDo - Init view with current name.  Change to Manual Entry, upon editing.

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
      }.padding([.bottom], 10)

      VStack {
        Text(label)
        Text(tempName)
      }
      .font(.title)
      .padding([.top], 10)

      VStack {
        if unitHmsDms {
          HmsInputView(decimalDegrees: $tempCoord.ra, prefix: "RA")
          DmsInputView(decimalDegrees: $tempCoord.dec, prefix: "DEC")
        } else {
          FloatInputView(doubleValue: $tempCoord.ra, prefix: "RA")
          FloatInputView(doubleValue: $tempCoord.dec, prefix: "DEC")
        }
      }
      .onAppear() {
        tempCoord.ra = coord.ra
        tempCoord.dec = coord.dec
//        tempName = name
      }
//      .onChange(of: tempRa){ _ in
//        name = "onChange"
//      }
      
      BigButton(label:"Apply") {
        coord.ra = tempCoord.ra
        coord.dec = tempCoord.dec
        name = tempName
        heavyBump()
        dismissView()
      }
      
      TargetListView(catalog: catalog,
                     targetTapAction: makeTargetCurrent,
                     unitHmsDms: unitHmsDms)
    }
    .navigationBarBackButtonHidden(true)
    .navigationBarTitle("") // needed for navigationBarHidden to work.
    .navigationBarHidden(true)

    .onAppear() {
      softBump()
    }
  }

  func makeTargetCurrent(tappedTarget: Target) {
    tempCoord.ra  = tappedTarget.ra
    tempCoord.dec = tappedTarget.dec
    tempName = tappedTarget.name
    softBump()
  }
}

struct RaInputView_Previews: PreviewProvider {
  @State static var testCoord = RaDec(ra: 97.5, dec: 0.25)
  @State static var name = "TestName"
  @State static var viewOptions = ViewOptions()
  @State static var useHmsDms = true
  @State static var guideModel = GuideModel()
  
  static var previews: some View {
    RaDecInputView(label: "Enter RA/DEC Pair",
                   coord: $testCoord,
                   name: $name,
                   unitHmsDms: useHmsDms,
                   catalog: guideModel.catalog)
      .environmentObject(viewOptions)
      .preferredColorScheme(.dark)
      .foregroundColor(viewOptions.appRedColor)
  }
}

