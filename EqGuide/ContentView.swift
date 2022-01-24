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

  @ObservedObject var guideModel:GuideModel

  var body: some View {
    NavigationView{
//      Spacer()
      
      VStack {
        HStack{
          Text("Status: ")
          Text(guideModel.statusString)
        }

        Spacer()
        
        VStack {
          Text("RA Count: \(guideModel.guideDataBlock.raCount)")
          Text("RA Deg:   \(guideModel.guideDataBlock.raDeg)")
          Text("RA Min:   \(guideModel.guideDataBlock.raMin)")
          Text("RA Sec:   \(guideModel.guideDataBlock.raSec)")
        }
        
        Spacer()
        
        VStack {
          Text("DEC Count: \(guideModel.guideDataBlock.decCount)")
          Text("DEC Deg:   \(guideModel.guideDataBlock.decDeg)")
          Text("DEC Min:   \(guideModel.guideDataBlock.decMin)")
          Text("DEC Sec:   \(guideModel.guideDataBlock.decSec)")
        }

        Spacer()
        
        HStack{
          Spacer()
          Button("Add 1 Deg EL") {
            let addCommand = GuideCommandBlock(
              command:GuideCommand.elAdd1Deg.rawValue,
              raOffset:10,
              decOffset:20)
            guideModel.guideCommand(addCommand)
          }
          Spacer()
          Button("Sub 1 Deg EL") {
            let subCommand = GuideCommandBlock(
              command:GuideCommand.elSub1Deg.rawValue,
              raOffset:-16,
              decOffset:-27)
            guideModel.guideCommand(subCommand)
          }
          Spacer()
        }

        Spacer()

        Text("readCount: \(guideModel.readCount)")

        Spacer()

//        VStack {
//          HStack {
//            Text("RA")
//            uiRaDec()
//          }
//          HStack {
//            Text("Dec")
//            uiRaDec()
//          }
//          NavigationLink {
//            ObjectListView()
//          } label: {
//            Text("Switch to Location Selector View")
//          }
//          .padding()
//          .navigationTitle("Guide Drive")
//        }
        
//        Spacer()
      } // Top Level VStack
      .onAppear{
        guideModel.guideModelInit()
      }
    } // NavigationView
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(guideModel: GuideModel())
      .previewDevice(PreviewDevice(rawValue: "iPhone Xs"))
      .previewInterfaceOrientation(.portrait)
  }
}

