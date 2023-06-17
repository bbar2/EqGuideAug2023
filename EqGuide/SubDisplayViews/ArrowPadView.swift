//
//  ArrowPadView.swift
//  EqGuide
//
//  Created by Barry Bryant on 6/12/23.
//

import SwiftUI

struct ArrowPadView: View {
  @ObservedObject var mountModel: MountBleModel

  @EnvironmentObject var viewOptions: ViewOptions

  var nullAction: ()->Void = {}

  var body: some View {
    VStack {
      Picker(selection: $mountModel.arrowPadSpeed,
             label: Text("???")) {
        Text("Fast").tag(ArrowMode.fast)
        Text("Slow").tag(ArrowMode.slow)
      } .pickerStyle(.segmented)
        .onChange(of: mountModel.arrowPadSpeed) { _ in
          softBump()
        }
      
      let speed :Int32 = mountModel.arrowPadSpeed == ArrowMode.fast ? 2 : 1
      
      TouchImage(systemName: "arrowtriangle.up",
                 touchAction: {
        mountModel.guideCommandMove(ra: 0, dec: speed)
        softBump()
      },
                 releaseAction: {
        mountModel.guideCommandMoveNull()
        softBump()
      })
      HStack {
        TouchImage(systemName: "arrowtriangle.left",
                   touchAction: {
          mountModel.guideCommandMove(ra: -speed, dec: 0)
          softBump()
        },
                   releaseAction: {
          mountModel.guideCommandMoveNull()
          softBump()
        })
        TouchImage(systemName: "x.square",
                   touchAction: {
          mountModel.guideCommandMoveNull()
//          mountModel.guideCommandReset()
          softBump()
        },
                   releaseAction: {
          softBump()
        })

        TouchImage(systemName: "arrowtriangle.right",
                   touchAction: {
          mountModel.guideCommandMove(ra: speed, dec: 0)
          softBump()
        },
                   releaseAction: {
          mountModel.guideCommandMoveNull()
          softBump()
        })
      }
      TouchImage(systemName: "arrowtriangle.down",
                 touchAction: {
        mountModel.guideCommandMove(ra: 0, dec: -speed)
        softBump()
      },
                 releaseAction: {
        mountModel.guideCommandMoveNull()
        softBump()
      })
    }
  }
}

struct ArrowPadView_Previews: PreviewProvider {
  static let previewGuideModel = MountBleModel()
  static var nullAction: ()->Void = {}

  static var previews: some View {
    ArrowPadView(mountModel: previewGuideModel)
      .environmentObject(ViewOptions())
      .preferredColorScheme(.dark)
  }
}
