//
//  Vallado.swift
//
//  Created by Barry Bryant
//  Modified on 4/17/22.
//
// Functions to build and manipulate Date() components in local and GMT TimeZones.
// Implementations of Vallado functions for calculating astronomical terms.
// NSDate based reference functions for examples.
//

import Foundation

// Dates are inherently UT, without TimeZone.  Equivalent to Dates in GMT.
// Calendar() shifts Date components to the Calendar.timeZone
// gmtComponents generates components for GMT TimeZone.
// So gmtComponents of a Date() will be shifted 4 or 5 hours depending on DST.
extension Date {
  func gmtComponents() -> DateComponents {
    var gmtCalendar = Calendar.current
    gmtCalendar.timeZone = TimeZone(abbreviation: "GMT")!
    return gmtCalendar.dateComponents(
      [.year, .month, .day, .hour, .minute, .second],
      from: self)
  }
}

extension Date {
  func localComponents() -> DateComponents {
    let localCalendar = Calendar.current
    return localCalendar.dateComponents(
      [.year, .month, .day, .hour, .minute, .second],
      from: self)
  }
}

// Use to debug at alternate times.
// Calculate this offset when app starts, and add it to the Date() every time
// you get a new Date().
func intevalTo(y: Int, m: Int, d: Int, h: Int, min: Int) -> TimeInterval {
  let altTime = utDateFromLocalTerms(y: y, m: m, d: d, h: h, min: min, sec: 0)
  return altTime.timeIntervalSinceNow
}

// Build a UT Date from Components specified in GMT TimeZone
public func utDateFromGmtTerms(y: Int, m: Int, d: Int,
                         h: Int = 0, min: Int = 0, sec: Int = 0) -> Date {
  var dateComponents = DateComponents()
  dateComponents.year = y
  dateComponents.month = m
  dateComponents.day = d
  dateComponents.hour = h
  dateComponents.minute = min
  dateComponents.second = sec
  var gmtCalendar = Calendar.current
  gmtCalendar.timeZone = TimeZone(abbreviation: "GMT")!
  return gmtCalendar.date(from:dateComponents) ?? Date()
}

// Build a UT Date from Components specified in local TimeZone
public func utDateFromLocalTerms(y: Int, m: Int, d: Int,
                         h: Int = 0, min: Int = 0, sec: Int = 0) -> Date {
  var dateComponents = DateComponents()
  dateComponents.year = y
  dateComponents.month = m
  dateComponents.day = d
  dateComponents.hour = h
  dateComponents.minute = min
  dateComponents.second = sec
  return Calendar.current.date(from:dateComponents) ?? Date()
}

// Algorithm 14 from p183 Vallado 4th Ed
// Result is within one second of jdFromDate below (~ 1e-6 different.  1 Sec ~ 1.16e-5)
public func jdFrom(utDate: Date) -> Double {
  
  let gmtComponents = utDate.gmtComponents()
  
  let year = Double(gmtComponents.year ?? 0)
  let month = Double(gmtComponents.month ?? 0)
  let day = Double(gmtComponents.day ?? 0)
  let hour = Double(gmtComponents.hour ?? 0)
  let min = Double(gmtComponents.minute ?? 0)
  let sec = Double(gmtComponents.second ?? 0)
  
  let a = Double(367.0 * year)
  let b = Double(Int((month + 9.0) / 12.0))
  let c = Double(Int((7.0 * (year + b)) / 4.0))
  let d = Double(Int(275.0 * month / 9.0))
  let e = Double(day + 1721013.5)
  let f = Double((((sec/60.0) + min) / 60.0) + hour) / 24.0
  
  let jd = a - c + d + e + f
  
  return jd
}

func julianCentury(utDate: Date) -> Double {
  let jd = jdFrom(utDate: utDate)
  
  // gmst uses JulianCenturies from jan,1,2000 12:00 PM = J2000.0
  // JD of Jan 1, 2000 12:00PM = 2451545.0
  return Double( (jd - 2451545.0) / (365.25 * 100) )
}

// Algorithm 15: From p188 Vallado 4th Ed
// Greenwich Mean Siderial Time
public func gmstDegFrom(utDate: Date) -> Double {
  
  let tjc = julianCentury(utDate: utDate)
  
  let t0 = Double(67310.54841)
  let t1 = Double(876600.0*3600.0 + 8640184.812866) * tjc
  let t2 = Double(0.093104) * pow(tjc, 2.0)
  let t3 = Double(6.2e-6) * pow(tjc, 3.0)
  
  let secondsInDay = Double(60.0 * 60.0 * 24.0)
  let gmstSecs = (t0 + t1 + t2 - t3).truncatingRemainder(dividingBy: secondsInDay)
  
  let gmstDeg = (gmstSecs / secondsInDay) * 360.0

  return gmstDeg.mapAngle0To360()
}

// Algorithm 15: From p215 Vallado 4th Ed
// Local Siderial Time
public func lstDegFrom(utDate: Date, localLongitudeDeg: Double) -> Double {
  let gmstDeg = gmstDegFrom(utDate: utDate)
  let lstDeg = gmstDeg + localLongitudeDeg

  return lstDeg.mapAngle0To360()
}

// Algorithm 15: From p215 Vallado 4th Ed
// Local Siderial Time
func lstDegFrom(gmstDeg: Double, localLongitudeDeg: Double) -> Double {
  let lstDeg = gmstDeg + localLongitudeDeg
  return lstDeg.mapAngle0To360()
}

// Utility func for figuring out what's going on
public func printDateComponents(_ label: String, _ date: Date) {
  let localComponents = date.localComponents()
  var year = localComponents.year!
  var month = localComponents.month!
  var day = localComponents.day!
  var hour = localComponents.hour!
  var min = localComponents.minute!
  var sec = localComponents.second ?? 0
  print(label)
  print("LocalDate: \(year)/\(month)/\(day)")
  print("LocalTime: \(hour):\(min):\(sec)")

  let gmtComponents = date.gmtComponents()
  year = gmtComponents.year!
  month = gmtComponents.month!
  day = gmtComponents.day!
  hour = gmtComponents.hour!
  min = gmtComponents.minute!
  sec = gmtComponents.second ?? 0
  print("GmtDate: \(year)/\(month)/\(day)")
  print("GmtTime: \(hour):\(min):\(sec)")

  print("DateString = \(date.description)\n")
}

// From https://astrogreg.com/convert_ra_dec_to_alt_az.html
// Although not directly from Vallado, consistent with Vallado eq 4-11 thru 4-14
// All input and output angles are in degrees
func raDecToAltAz(lstDeg: Double, latDeg:Double, raDeg:Double, decDeg:Double) ->
(altDeg: Double, azDeg:Double, haDeg:Double) {
  
  let haDeg = lstDeg - raDeg
  
  let ha = haDeg.degToRad()
  let dec = decDeg.degToRad()
  let lat = latDeg.degToRad()
  
  let alt: Double = asin(
    sin(dec)*sin(lat) +
    cos(dec)*cos(lat)*cos(ha)
  )
  
  var az: Double = atan2(sin(ha), cos(ha)*sin(lat)-tan(dec)*cos(lat))
  az = az - Double.pi
  
  return(alt.radToDeg().mapAnglePm180(), // alt will be pm90
         az.radToDeg().mapAnglePm180(), // I like pm180, though az standard is 0to360
         haDeg.mapAnglePm180())
}


