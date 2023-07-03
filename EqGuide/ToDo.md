Can I write freeform text in here.  Apparently yes.
Do I get spel checking.  No.

# ToDo - Date put on list. Top Priority at top of list. 

2023-07-02: After GOTO EastPier, PierDeg should be -90 and it's +90
2023-06-16: Review/Update reference confidence:  updateOffsetsTo(reference:) should update confidence to estimated value.  MarkRef should change to highest value. 
2023-06-08: Focus - Connect and Start BLE.  Only auto disconnect after first Mark. Leave a disconnect button.  Remove all XL data stuff from this page.
2023-06-18: Add Lat/Long to hardware view, with option for manual entry. Consider an alternate date and a Time offset?
2023-07-02: While guiding to a target, Pause Tracking to improve accuracy.
2023-06-17: Add a 30 degree RA button to help with Polemaster alignment operation.
2023-06-17: Hardware Red button, should also neutralize ios move commands. Directly, and probably through the data block sent to ios.
2023-06-08: Hardware - Blend BLE Yellow indicators into the accel/angle table lables, and maybe columns.  Columns might be too much yellow.
2023-06-08: Decide on colors for Gray/Disabled, Yellow/NoBle, Red/Good.  When to use yellow vs gray.  Use the orange from LST app.
2022-05-27: GUI reconfigure - No functional change to GuideMount
  New main Guide with: 
    BLE Link indication for all three BLE devices - for status display
    East/West Pier indicator, 
    AZ/EL conversion
    Done - Current RA/DEC (Yellow from angle, Red from Ref)
    Done - LST, Lat, Long
    Done - Target RA/DEC - select and swap controls
    Done - Ref RA/DEC - select control
    Done - Pause Guiding Control.
    Done - Swap and Set Target and Ref Control which transmits to mount
2023-05-27: Targ mode not working as expected. Ref/Targ mode works well.
2023-05-27: Shutdown should be more orderly.  Close BLE connections, then shutdown.
2023-04-23: When I Set East Pier, it's only correct for an instant. Running making the reference error increase.  
2022-10-12: Add a way to select the fixed angle refPierVert/East/West reference points. 
2022-05-07: Add filters to TargetList.  At least filter by constellation and type
2022-05-07: Add ability to see description for each TargetList Item.  Impacts how UI works.
2022-05-05: LST should run, even if BLE not conntected.  Probably own timer.
2022-10-10: Add time varying coordinates for Planets - or just enter them manually at show time. 
2022-04-06: This is a Mark Down file. What are formating options in md files? 

# Done Items - Newest on top.  Date item completed.

2023-06-16: Done - GoTo's should update current coordinates 
2023-06-18: Done - App shutdown needs to issue a Move Neutral command.  Maybe invalidate timers too.
2023-06-17: Done - Guide and Manual - Put track/Stop view on bottom of page. 
2023-06-17: Done - Reset should invalidate Home and EastPier timers.
2023-06-16: Done - Guide - execute SetTarget&Ref everytime target or ref change.  Remove button.
2023-06-16: Done - Guide - Rearrange Swap, Mark, and GoTo.
2023-06-16: Done - Manual - Create ArrowCluster view, and track/Stop view.
2022-06-16: Done - Consider allowing app to remotely issue the Mark and Guide commands, to enable remote operation. Not necessarily after adding joystick capability.  
2022-06-15: Done - Add joystick capability to Guide App.  Include DMS step buttons? - If I do it, put it in a separate View.
2023-06-11: Done - Pause RA Tracking, now leaves RA/DEC joystick control enabled
2022-06-10: Hardware page showing raw accel, aligned accel, maybe unaligned accel for guide mount accel, pier accel and focus accel.  If space, add guide mount counts and time. Include enough info to support generating alignmnet angles, and accel calibrations.  
2023-05-25: Done - Develop EqGuide Accelerometer to three angles conversions. El, RA, Dec.
2022-05-15: Done - After two BLE links, Add FocusMotor transmit acceleromter data to EqGuide.
2023-05-15: Done - After two BLE links, Integrate FocusControl as a separate Top level tab.
2023-05-01: Done - Get two BLE links running.  One to Mount, one to Focus.
2022-10-00: Done - Create Icon - move to Assets - plan to use FocusControl icon.
2022-05-29: Done - Add Tracking on/off switch
2022-05-29: Done - Add Latiude someplace, to aid in wedge angle setup
2022-05-29: Done - Switch speed adjustment from milli Deg / min, to arc sec / min
2022-05-27: Done - Add tracking speed control tab with Lunar and Star option.
2022-05-27: Done - Add numeric speed offset input to tracking speed control tab. 
2022-05-27: Done - Any edit should change coord name to Manual Entry.
2022-05-27: Done with raise/lower/next arrow button - Add overylay to RaDecInput view, so tapping outside keyboard will close it. 
2022-05-07: Done by changing DirectOffset to CurrentToTarget - Either a "Current To Ref Pos" Button, or add a "GoTo Target from Current"   
2022-05-07: Done - Update GuideView's OffsetToTarget View to show PierAngle and DiskAngle
2022-05-06: Done - Create and read json file with target offsets. Update UI to set reference and target from json based list. 
2022-05-06: Done - Top level decimal degree or Deg/Hour and Minute switch.  Keep on screen at all times.
2022-05-05: OBE Since basic equations do the flip.  Manual Top level Declination invert button, so support operation after azimuth flip. This could be automated after reading focus motor accelerometers, but might still be needed for times the focus motor is not on board, or down, or before reference angle set.   
2022-05-04: OBE - Removed reversals from Mount.  When Mount reverses offset after a guide, update the EqApp so it's clear where next offset will take it. 
2022-05-02: Done - Fix DiskAngleOffset calc to use +180
2022-05-02: Done - Coordinate Current Position and Pier Angle once a reference is "Marked".
2022-04-20: Done - Siderial location of Pier from current siderial time and Pier Angle.  
2022-04-20: Done - Current time and date to Siderial time straight above.
2022-04-09: Done, added to Title line - Add MountState indicator to GUideDataBlock and EqGuide Guide View. 
2022-04-08: Done - Make UI view font sizes and colors consistent by storing in Environmnet Object. 
2022-04-08: Done - Stub in tab view with dummy focus page, to aid in top level UI layout.
2022-04-08: Done - Get RocketMount and EqGuide working with Direct offset or TargetOffset modes.
2022-04-06: Decide on file format for angles.  DMS, Float, or Double.
   Done - Use Int HM(Seconds Optionsal) for Right Ascension and DM(Seconds Optional) for Declination.  Internally, everything is decimal Float32.
2022-04-06: Decide on basic page layout.  Main with command buttions, offset inputs (absolute, or target), current position (absolute or target)
2022-03-01: Done - Command flow from EqGuide to RocketMount.  Initial use to turn on and off the flow of Az data.  Only flow it while parameter display view is active.  
    Decided to use Notify for data from RocketMount to EqGuide.  Mount is always writing if BLE connection established.  Really, BLE connection establishment is regulating the flow of data. Commands only flow from EqGuide on button presses.  Only commands at this time are set absolute offset (just move this much), and set relative offset (Mark reference, then move this much).  For now, all movement initiated from hardware pendant, so hardwired stop button is always handy. 
2022-03-01: Initial Data from from RocketMount.cpp to EqGuide. Start with RA count.  Figure out how to update at desired freq, independent of how frequently it updates in RocketMount.  
2022-03-01: Done - Initial BLE connection - OK - calling from onAppear.  It should init once, and not every time that view appears.  Need to move the init call to an applicaiton level init. Done - moved into EqGuideApp.
