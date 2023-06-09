//
//  ManualView.swift
//  Manual control view.  GUI version of hardware joystick, with additional
//  capability to drive to Home or East Pier based on accelerometer feedback.
//
//
//  Created by Barry Bryant on 6/9/23.
//

import SwiftUI

struct ManualView: View {
  @ObservedObject var mountModel: MountBleModel
  @EnvironmentObject var viewOptions: ViewOptions

  var body: some View {
    
    VStack {
      
      Text("Manual Control").font(.title)
      
      Spacer()
      
      HStack {
        Spacer()
        BigButton(label:"HOME") {
          heavyBump()
        }
        Spacer()
        BigButton(label:"EAST\nPIER") {
          heavyBump()
        }
        Spacer()
      }
      
      Spacer()
      
      Picker(selection: $mountModel.arrowMode,
             label: Text("???")) {
        Text("Fast").tag(ArrowMode.fast)
        Text("Medium").tag(ArrowMode.medium)
        Text("Slow").tag(ArrowMode.slow)
      } .pickerStyle(.segmented)
        .onChange(of: mountModel.arrowMode) { _ in
          softBump()
        }
      HStack {
        Spacer()
        BigButton(label:"+\nDEC") {
          heavyBump()
        }
        Spacer()
      }
      HStack {
        Spacer()
        BigButton(label:"-\nRA") {
          heavyBump()
        }
        Spacer()
        BigButton(label:"+\nRA") {
          heavyBump()
        }
        Spacer()
      }
      HStack {
        Spacer()
        BigButton(label:"-\nDEC") {
          heavyBump()
        }
        Spacer()
      }
      
      Spacer()
      
      HStack{
        Toggle("RA Tracking", isOn: $mountModel.raTracking)
          .toggleStyle(.automatic)
        Spacer()
        BigButton(label:"STOP") {
          heavyBump()
        }
        Spacer()
      }
      
    } // end Main VStack
    
  }
}

struct ManualView_Previews: PreviewProvider {
  static let viewOptions = ViewOptions()
  static let previewGuideModel = MountBleModel()

  static var previews: some View {
    ManualView(mountModel: previewGuideModel)
      .environmentObject(viewOptions)
      .preferredColorScheme(.dark)
      .foregroundColor(viewOptions.appRedColor)
  }
}
