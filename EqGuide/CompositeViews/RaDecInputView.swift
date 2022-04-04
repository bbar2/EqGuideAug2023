//
//  RaInputView.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/27/22.
//

import SwiftUI

struct RaDecInputView: View {
  
  var label:String
  @Binding var coord:RaDec
  
  @State private var tempRaDec = RaDec()
  @State private var editInFloat = true
  @Environment(\.dismiss) private var dismissView
  
  var body: some View {
    
    VStack {
      HStack{
        Button{
          dismissView()
        } label: {
          Text("< Cancel").font(.title3).bold()
        }
        Spacer()
      }
      Text(label)
        .font(.title)
        .padding([.top], 20)
      
      VStack {
        if editInFloat {
          FloatInputView(floatValue: $tempRaDec.ra, prefix: "RA")
          FloatInputView(floatValue: $tempRaDec.dec, prefix: "DEC")
        } else {
          DmsInputView(decimalDegrees: $tempRaDec.ra, prefix: "RA")
          DmsInputView(decimalDegrees: $tempRaDec.dec, prefix: "DEC")
        }
      }
      Button() {
        editInFloat = !editInFloat
      } label: {
        Text(editInFloat ? "Switch to DMS" : "Switch To Decimal Degrees")
          .font(.title2)
          .bold()
      }
      .onAppear() {
        tempRaDec = coord
      }
      
      BigButton(label:"Apply") {
        coord  = tempRaDec
        dismissView()
      }
      Spacer()
    }
    .navigationBarBackButtonHidden(true)

  }
}

struct RaInputView_Previews: PreviewProvider {
  @State static var testCoord = RaDec(ra: 97.5, dec: 0.25)
  static var previews: some View {
    RaDecInputView(label: "Enter RA/DEC Pair", coord: $testCoord)
  }
}

