//
//  DegreeButton.swift
//  EqGuide
//
//  Created by Barry Bryant on 7/3/23.
//

import SwiftUI

struct DegreeFormatControl: View {
  
  @EnvironmentObject var viewOptions: ViewOptions
  
  var body: some View {
    Button() {
      viewOptions.showDmsHms = !viewOptions.showDmsHms
    } label: {
      Text(viewOptions.showDmsHms ? "DMS/HMS" : "Degrees")
        .foregroundColor(viewOptions.appActionColor)
        .font(viewOptions.smallHeaderfont).bold()
    }
  }
  
  struct DegreeButton_Previews: PreviewProvider {
    static var previews: some View {
      DegreeFormatControl()
        .environmentObject(ViewOptions())
    }
  }
}

