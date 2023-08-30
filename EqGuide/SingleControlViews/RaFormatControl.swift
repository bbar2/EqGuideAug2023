//
//  RaFormatControl.swift
//  EqGuide
//
//  Created by Barry Bryant on 8/28/23.
//

import SwiftUI

struct RaFormatControl: View {
  
  @EnvironmentObject var viewOptions: ViewOptions
  
  var body: some View {
    Button() {
      viewOptions.showRaAsHA = !viewOptions.showRaAsHA
    } label: {
      Text(viewOptions.showRaAsHA ? "HA" : "RA")
        .foregroundColor(viewOptions.appActionColor)
        .font(viewOptions.smallHeaderfont).bold()
    }
  }
  
  struct RaFormatControl_Previews: PreviewProvider {
    static var previews: some View {
      RaFormatControl()
        .environmentObject(ViewOptions())
    }
  }
}

