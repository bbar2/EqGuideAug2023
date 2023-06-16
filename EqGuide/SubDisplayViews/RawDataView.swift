//
//  rawDataView.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/26/22.
//

import SwiftUI
import simd

struct RawDataView: View {
  var gdb:GuideDataBlock
 
  struct AccelView: View {
    var label: String
    var value: Float
    var format: String = "%.2f"
    
    var body: some View {
      Text(String(format: label + format, value))
    }
  }
  
  var body: some View {
    VStack(alignment: .leading){
      Divider()
      HStack {
        Text("Counts")
        Spacer()
        Text("RA: \(gdb.armCount)")
        Spacer()
        Text("Dec: \(gdb.dskCount)")
      }

      HStack {
        AccelView(label: "RawAx: ", value: gdb.accel_x)
        Spacer()
        AccelView(label: "RawAy: ", value: gdb.accel_y)
        Spacer()
        AccelView(label: "RawAz: ", value: gdb.accel_z)
      }

      let totalSeconds = gdb.mountTimeMs / UInt32(1000)
      let hour = totalSeconds / UInt32(3600)
      let minSecs = totalSeconds % UInt32(3600)
      let minute = minSecs / UInt32(60)
      let second = minSecs % UInt32(60)
      
      Text(String(format: "Mount Time  h:%d   m:%02d   s:%02d", hour, minute, second))
      
      Divider()
    }
    .padding([.leading, .trailing], 5)

  }
}

struct rawDataView_Previews: PreviewProvider {
  static var previews: some View {
    RawDataView(gdb: GuideDataBlock())
      .preferredColorScheme(.dark)
  }

}
