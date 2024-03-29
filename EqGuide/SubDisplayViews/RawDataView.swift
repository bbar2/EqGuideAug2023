//
//  rawDataView.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/26/22.
//

import SwiftUI
import simd

struct RawDataView: View {
  var gdb:MountDataBlock
 
  @EnvironmentObject var viewOptions: ViewOptions
  
  var body: some View {
    VStack(alignment: .leading){
      Divider()
      HStack {
        Text("Counts")
        Spacer()
        Text("RA: \(gdb.pierCount)")
        Spacer()
        Text("Dec: \(gdb.diskCount)")
      }

      let totalSeconds = gdb.mountTimeMs / UInt32(1000)
      let hour = totalSeconds / UInt32(3600)
      let minSecs = totalSeconds % UInt32(3600)
      let minute = minSecs / UInt32(60)
      let second = minSecs % UInt32(60)
      
      Text(String(format: "Mount Time  h:%d   m:%02d   s:%02d", hour, minute, second))
      
      Divider()
    }
    .font(viewOptions.bigValueFont)
    .padding([.leading, .trailing], 5)
  }
}

struct rawDataView_Previews: PreviewProvider {
  static var previews: some View {
    RawDataView(gdb: MountDataBlock())
      .preferredColorScheme(.dark)
  }

}
