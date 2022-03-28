//
//  ContentView.swift
//  Guide
//
//  Created by Barry Bryant on 12/18/21.
//

import SwiftUI

//struct uiRaDec:View {
//  @State private var dec:Int32?
//
//  var body: some View {
//    HStack {
//      TextField("deg", value:$dec, format:.number).fixedSize(horizontal: true, vertical: true)
//      TextField("min", value:$dec, format:.number).fixedSize(horizontal: true, vertical: true)
//      Text("sec, \(dec ?? 0)")
//    }
//  }
//}

struct ContentView: View {
  
  @ObservedObject var guideModel:GuideModel
  
  var body: some View {
    GuideView(guideModel: guideModel)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(guideModel: GuideModel())
      .previewDevice(PreviewDevice(rawValue: "iPhone Xs"))
      .previewInterfaceOrientation(.portrait)
  }
}

