//
//  ViewOptions.swift
//  EqGuide
//
//  Created by Barry Bryant on 4/23/22.
//

import SwiftUI

final class ViewOptions: ObservableObject {
  @Environment(\.colorScheme) var colorScheme
    
  @Published var forceDarkMode = false

  @Published var showDmsHms: Bool = true;
  
  let appRedColor = Color(red:159/255, green: 0, blue: 0)
  let appActionColor = Color(red:200.0/255.0, green: 0, blue: 0)
  static let myGray = 50.0 / 255.0
  let appDisabledColor = Color(red: myGray, green: myGray, blue: myGray)
  let confNoneColor = Color(.yellow)
  let confEstColor = Color(.orange)
  let noBleColor = Color(.yellow)
  let thumbColor = Color(red: 0.2, green: 0.0, blue: 0.0)
  let thumbBarColor = Color(red: 0.05, green: 0.0, blue: 0.0)

  var fontColor : Color {
    return (forceDarkMode || colorScheme == .dark ? appRedColor : .black)
  }
    
  let appHeaderFont = Font.system(.title).monospacedDigit()
  let labelFont = Font.system(.title3)
  let bigValueFont = Font.system(.title2).bold().monospacedDigit()
  let smallValueFont = Font.system(.body).monospacedDigit()
  let noteFont =  Font.system(.body)
  let smallHeaderfont = Font.headline.weight(.light)
  
  let leadingPad = CGFloat(10)
  let trailingPad = CGFloat(10)

  func setupSegmentControl() {
    // Set color of "thumb" that selects between items
    UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(thumbColor)
    
    // Set color for whole "bar" background
    UISegmentedControl.appearance().backgroundColor = UIColor(thumbBarColor)
    
    // Set font attributes - call once for each state (.normal, .selected)
    UISegmentedControl.appearance().setTitleTextAttributes(
      [.font : UIFont.preferredFont(forTextStyle: .title2),
       .foregroundColor : UIColor(appActionColor)], for: .normal)
    
    UISegmentedControl.appearance().setTitleTextAttributes(
      [.foregroundColor : UIColor(appActionColor),
       .font : UIFont.preferredFont(forTextStyle: .title1)], for: .selected)
  }

}
