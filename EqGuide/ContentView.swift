//
//  ContentView.swift
//  Guide
//
//  Created by Barry Bryant on 12/18/21.
//

import SwiftUI

struct uiRaDec:View {
  @State private var dec:Int32?
  
  var body: some View {
    HStack {
      TextField("deg", value:$dec, format:.number).fixedSize(horizontal: true, vertical: true)
      TextField("min", value:$dec, format:.number).fixedSize(horizontal: true, vertical: true)
      Text("dec, \(dec ?? 0)")
    }
  }
}

struct ContentView: View {

  @ObservedObject var guideModel = GuideModel()

  var body: some View {
    NavigationView{
      VStack {
        Spacer()
        HStack{
          Text("Status: ")
          Text(guideModel.statusString)
        }

        Spacer()
        
        Text("Var1: \(guideModel.var1)")
        Text("Word1: \(guideModel.guideDataBlock.word1)")
        Text("Word2: \(guideModel.guideDataBlock.word2)")
        Text("readCount: \(guideModel.readCount)")

//        Spacer()

        HStack {
          Text("RA")
          uiRaDec()
        }
        HStack {
          Text("Dec")
          uiRaDec()
        }
        NavigationLink {
          ObjectListView()
        } label: {
          Text("Switch to Location Selector View!")
        }
        .padding()
        .navigationTitle("Guide Drive")
//        Spacer()
      } // VStack
      .onAppear{
        guideModel.guideModelInit()
      }
    } // NavigationView
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .previewDevice(PreviewDevice(rawValue: "iPhone Xs"))
      .previewInterfaceOrientation(.portrait)
  }
}

