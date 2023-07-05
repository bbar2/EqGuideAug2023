//
//  RaRateView.swift
//  EqGuide
//
//  Created by Barry Bryant on 5/23/22.
//

import SwiftUI

struct RaRateView: View {
  @ObservedObject var mountModel: MountBleModel
  
  @EnvironmentObject var viewOptions: ViewOptions
  
  @State private var newOffsetArcSecPerMin = Double(0.0)
  
  enum TrackMode {
    case star
    case lunar
  }
  @State var trackMode: TrackMode = .star
  
  var body: some View {
    VStack {
      VStack {
        Text("Tracking Mode").font(viewOptions.appHeaderFont)
        Picker(selection: $trackMode,
               label: Text("???")) {
          Text("Stars")
            .tag(TrackMode.star)
          Text("Moon")
            .tag(TrackMode.lunar)
        }
               .pickerStyle(.segmented)
        //               .padding([.leading, .trailing], 60)
        
        Image(systemName: trackMode == .star ? "star": "moon").font(.system(size:100))
        //          .padding([.top], 30)
          .fixedSize(horizontal: true, vertical: true)
        
        switch trackMode {
          case .star:
            Text("Star Track Mode").font(viewOptions.labelFont)
          case .lunar:
            Text("Use -32 arcSec / min").font(viewOptions.labelFont)
        }
        
        let currentArcSecPerMin = 3600.0 * 60.0 * mountModel.guideDataBlock.raRateOffsetDegPerSec
        Text(String(format: "Current Offset: %.0f arcSec/min", currentArcSecPerMin))
          .font(viewOptions.labelFont)
        //.padding([.bottom], 20)
      }
      
      
      Spacer()
      
      VStack{
        Text("New Fine Tune Offset").font(viewOptions.appHeaderFont)
        Text("arcSec / min (+ccw)").font(viewOptions.labelFont)
        HStack {
          Spacer()
          DoubleInputView(doubleValue: $newOffsetArcSecPerMin,
                          prefix: "",
                          numDigits: 0)
          //.padding([.top], -10)
        }
      }
      
      
      Spacer()
      
      BigButton(label: "Update\nFine Tune\n Offset", minWidth: 200) {
        let newDegPerSec = newOffsetArcSecPerMin / (3600.0 * 60.0)
        mountModel.guideCommandSetRaRateOffsetDps(newDps: newDegPerSec)
      }
      
      Spacer()
      
      StopControlView(mountModel: mountModel)
      
      BleStatusView(mountModel: mountModel)
      
    } // Top Level VStack
    .foregroundColor(viewOptions.appRedColor)
    .onAppear{
      viewOptions.setupSegmentControl()
    }
    .ignoresSafeArea(.keyboard)
  } // body
} // RaRateView

struct RaRateView_Previews: PreviewProvider {
  static let model = MountBleModel()
  static let viewOptions = ViewOptions()
  
  static var previews: some View {
    RaRateView(mountModel: model)
      .environmentObject(viewOptions)
      .preferredColorScheme(.dark)
      .previewDevice(PreviewDevice(rawValue: "iPhone Xs"))
  }
}
