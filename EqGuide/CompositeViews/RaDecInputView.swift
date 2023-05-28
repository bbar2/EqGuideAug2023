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

  private let ManualEntry = "User Coord"
  @State private var tempCoord = RaDec()
  @State private var editCoord = RaDec()
  @State private var tempName = ""

  var body: some View {
    
    VStack {
      Divider()
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
          HmsInputView(decimalDegrees: $editCoord.ra, prefix: "RA")
          DmsInputView(decimalDegrees: $editCoord.dec, prefix: "DEC")
        } else {
          DoubleInputView(doubleValue: $editCoord.ra, prefix: "RA")
          DoubleInputView(doubleValue: $editCoord.dec, prefix: "DEC")
        }
      }

      BigButton(label:"Apply") {
        coord = tempCoord
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
      tempCoord = coord
      editCoord = coord
      tempName = name
      softBump()
    }
    
    // Detect manual coordinate edits, and rename the coordinate
    .onChange(of: editCoord.ra) { newValue in
      if abs(tempCoord.ra - newValue) > 0.01 { // watch string to double truncation
        tempName = ManualEntry
      }
      tempCoord.ra = newValue
    }
    .onChange(of: editCoord.dec) { newValue in
      if abs(tempCoord.dec - newValue) > 0.01 { // watch string to double truncation
        tempName = ManualEntry
      }
      tempCoord.dec = newValue
    }
  }

  func makeTargetCurrent(tappedTarget: Target) {
    tempCoord.ra  = tappedTarget.ra
    tempCoord.dec = tappedTarget.dec
    editCoord = tempCoord
    tempName = tappedTarget.name
    softBump()
  }
}

struct RaInputView_Previews: PreviewProvider {
  @State static var testCoord = RaDec(ra: 97.5, dec: 0.25)
  @State static var name = "TestName"
  @State static var viewOptions = ViewOptions()
  @State static var useHmsDms = true
  @State static var guideModel = MountPeripheralModel()
  
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

