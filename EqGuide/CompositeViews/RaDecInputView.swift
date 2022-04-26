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
  @Binding var editInFloat:Bool

  @EnvironmentObject var viewOptions: ViewOptions

  @State private var tempRaDec = RaDec()
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

      Text(label)
        .font(.title)
        .padding([.top], 20)

      VStack {
        if editInFloat {
          FloatInputView(floatValue: $tempRaDec.ra, prefix: "RA")
          FloatInputView(floatValue: $tempRaDec.dec, prefix: "DEC")
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
      Spacer()
    }
    .navigationBarBackButtonHidden(true)
    .navigationBarTitle("") // needed for navigationBarHidden to work.
    .navigationBarHidden(true)

    .onAppear() {
      softBump()
    }

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

struct RaInputView_Previews: PreviewProvider {
  @State static var testCoord = RaDec(ra: 97.5, dec: 0.25)
  @State static var viewOptions = ViewOptions()
  @State static var editInFloat = true
  
  static var previews: some View {
    RaDecInputView(label: "Enter RA/DEC Pair",
                   coord: $testCoord,
                   editInFloat: $editInFloat)
      .environmentObject(viewOptions)
      .preferredColorScheme(.dark)
      .foregroundColor(viewOptions.appRedColor)
  }
}

