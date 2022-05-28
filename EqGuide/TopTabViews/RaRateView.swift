//
//  RaRateView.swift
//  EqGuide
//
//  Created by Barry Bryant on 5/23/22.
//

import SwiftUI

struct RaRateView: View {
  @ObservedObject var guideModel: GuideModel
  
  @EnvironmentObject var viewOptions: ViewOptions
  
  @State private var newMilliDegPerMin = Double(0.0)

  enum TrackMode {
    case star
    case lunar
  }
  @State var trackMode: TrackMode = .star
  
  var body: some View {
    ScrollView{
      
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
               .padding([.leading, .trailing], 60)
        
        Image(systemName: trackMode == .star ? "star": "moon").font(.system(size:100))
          .padding([.top], 30)
          .fixedSize(horizontal: true, vertical: true)
        
        switch trackMode {
          case .star:
            Text("Star Track Mode").font(viewOptions.labelFont)
          case .lunar:
            Text("Use -8.9 milliº / min").font(viewOptions.labelFont)
        }

        let currentMilliDegPerMin = 60.0 * 1000.0 * guideModel.guideDataBlock.raRateOffsetDegPerSec
        Text(String(format: "Current Offset: %.1f milliº/min", currentMilliDegPerMin))
          .font(viewOptions.labelFont)
      }
      .padding([.bottom], 30)

      VStack{
        Text("Fine Tuning Offset").font(viewOptions.appHeaderFont)
        Text("(milliº / min)").font(viewOptions.labelFont)
        HStack {
          Spacer()
          DoubleInputView(doubleValue: $newMilliDegPerMin,
                          prefix: "",
                          numDigits: 1).padding([.top], -10)
        }
        
      }

      BigButton(label: "Update\nFine Tunning\n Offset") {
        let newDps = newMilliDegPerMin / (1000.0 * 60.0);
        guideModel.guideCommandSetRaRateOffsetDps(newDps: newDps)
      }
      .padding([.top], 30)

      Spacer()
    }
    .foregroundColor(viewOptions.appRedColor)
    .onAppear{
      viewOptions.setupSegmentControl()
    }

  }
}

struct RaRateView_Previews: PreviewProvider {
  static let model = GuideModel()
  static let viewOptions = ViewOptions()
  
  static var previews: some View {
    RaRateView(guideModel: model)
      .environmentObject(viewOptions)
      .preferredColorScheme(.dark)
      .previewDevice(PreviewDevice(rawValue: "iPhone Xs"))
  }
}
