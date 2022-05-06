//
//  Target.swift
//  EqGuide
//
//  Created by Barry Bryant on 5/5/22.
//

import Foundation
import SwiftUI

// Target struct with properties matching names of some keys in TargetkData.json.
// Implies that don't have to match all keys in json file.
// Each json record must contain all keys defined in Target struct.
// List() usage needs Identifiable, and the id member.
// JSON reading and writing want's Codable, maybe Hashable too.
struct Target: Hashable, Codable, Identifiable {

  enum Category: String, CaseIterable, Codable {
    case star = "Star"
    case multiStar = "MultiStar"
    case catalog = "Galaxy"
    case nebula = "Nebula"
    case planet = "Planet"
  }

  var id: Int
  var name: String
  var description: String
  var constellation: String
  var category: Category
  var ra: Double
  var dec: Double
  var mag: Double
}
