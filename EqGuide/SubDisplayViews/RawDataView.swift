//
//  rawDataView.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/26/22.
//

import SwiftUI

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
        Text("RA: \(gdb.raCount)")
        Spacer()
        Text("Dec: \(gdb.decCount)")
      }

      HStack {
        AccelView(label: "Ax: ", value: 0.0)
        Spacer()
        AccelView(label: "Ay: ", value: 1.0)
        Spacer()
        AccelView(label: "Az: ", value: -1.0)
      }

      let totalSeconds = gdb.mountTimeMs / UInt32(1000)
      let hour = totalSeconds / UInt32(3600)
      let minSecs = totalSeconds % UInt32(3600)
      let minute = minSecs / UInt32(60)
      let second = minSecs % UInt32(60)
      Text("Mount Time    h:\(hour)   m:\(minute)   s:\(second)")
      
      Divider()
    }
    .padding([.leading, .trailing], 5)

  }
}

struct rawDataView_Previews: PreviewProvider {
  static var previews: some View {
    RawDataView(gdb: GuideDataBlock())
  }
}
