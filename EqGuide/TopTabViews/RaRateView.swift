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
        Text("Adjust Track Rate").font(viewOptions.appHeaderFont)
        
        Text(" ").font(viewOptions.smallHeaderfont)
        StatusBarView(mountModel: mountModel)
        Divider()
      }
      
      VStack {
        Picker(selection: $trackMode,
               label: Text("???")) {
          Text("Stars")
            .tag(TrackMode.star)
          Text("Moon")
            .tag(TrackMode.lunar)
        }
               .pickerStyle(.segmented)
        
        Image(systemName: trackMode == .star ? "star": "moon").font(.system(size:100))
          .fixedSize(horizontal: true, vertical: true)
        
        switch trackMode {
          case .star:
            Text("Star: Start with 0 acrSec/min").font(viewOptions.labelFont)
          case .lunar:
            Text("Lunar: Start with -32 arcSec/min").font(viewOptions.labelFont)
        }
        
        let currentArcSecPerMin = 3600.0 * 60.0 * mountModel.mountDataBlock.raRateOffsetDegPerSec
        Text(String(format: "Current Rate Offset: %.0f arcSec/min", currentArcSecPerMin))
          .font(viewOptions.labelFont)
        Divider()
      }
      
 //     Spacer()
      
      VStack {
        Text("New Rate Offset").font(viewOptions.appHeaderFont)
        Text("arcSec / min").font(viewOptions.labelFont)
        DoubleInputView(doubleValue: $newOffsetArcSecPerMin,
                        prefix: "(+west)",
                        numDigits: 0)
            
        BigButton(label: "Update\nRate Offset", minWidth: 200, minHeight: 90) {
          let newDegPerSec = newOffsetArcSecPerMin / (3600.0 * 60.0)
          mountModel.guideCommandSetRaRateOffsetDps(newDps: newDegPerSec)
        }
        Divider()
      }

      Spacer()
      
      StopControlView(mountModel: mountModel)
      
    } // Top Level VStack
    .foregroundColor(viewOptions.appRedColor)
    .onAppear{
      softBump()
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
