Can I write freeform text in here.  Apparently yes.
Do I get spel checking.  No.

# ToDo - Date put on list. Top Priority at top of list. 
2023-04-23: Make sure I'm on Main branch.
2022-04-06: Get two BLE links running.  One to Mount, one to Focus.
2022-04-06: After two BLE links, Integrate FocusControl as a separate Top level tab.
2022-04-06: After two BLE links, Add FocusMotor transmit acceleromter data to EqGuide.
2022-04-06: Develop EqGuide Accelerometer to three angles conversions. El, RA, Dec.
2022-10-12: Add a way to select the fixed angle refArmVert/East/West reference points. 
2022-10-03: Power up should not go to ReadyGuide, after pre power cycle state was ReadyGuide.
2022-05-29: Add Tracking on/off switch
2022-05-07: Add filters to TargetList.  At least filter by constellation and type
2022-05-07: Add ability to see description for each TargetList Item.  Impacts how UI works.
2022-05-05: LST should run, even if BLE not conntected.  Probably own timer.
2022-04-09: Why do I get one MarkRefNow on EqGuide reset. 
2022-04-08: Make UI view font sizes and colors consistent by storing in Environmnet Object. 
2022-04-06: Include DMS step buttons? - If I do it, put it in a separate View.
2022-10-10: Add time varying coordinates for Planets - or just enter them manually at show time. 
2022-05-21: Consider allowing app to remotely issue the Mark and Guide commands, to enable remote operation.
2022-04-06: This is a Mark Down file. What are formating options in md files? 

# Done Items - Newest on top.  Date item completed.
2022-10-00: Create Icon - move to Assets - plan to use FocusControl icon. 
2022-05-29: Done - Add Latiude someplace, to aid in wedge angle setup
2022-05-29: Done - Switch speed adjustment from milli Deg / min, to arc sec / min
2022-05-27: Done - Add tracking speed control tab with Lunar and Star option.
2022-05-27: Done - Add numeric speed offset input to tracking speed control tab. 
2022-05-27: Done - Any edit should change coord name to Manual Entry.
2022-05-27: Done with raise/lower/next arrow button - Add overylay to RaDecInput view, so tapping outside keyboard will close it. 
2022-05-07: Done by changing DirectOffset to CurrentToTarget - Either a "Current To Ref Pos" Button, or add a "GoTo Target from Current"   
2022-05-07: Done - Update GuideView's OffsetToTarget View to show ArmAngle and DiskAngle
2022-05-06: Done - Create and read json file with target offsets. Update UI to set reference and target from json based list. 
2022-05-06: Done - Top level decimal degree or Deg/Hour and Minute switch.  Keep on screen at all times.
2022-05-05: OBE Since basic equations do the flip.  Manual Top level Declination invert button, so support operation after azimuth flip. This could be automated after reading focus motor accelerometers, but might still be needed for times the focus motor is not on board, or down, or before reference angle set.   
2022-05-04: OBE - Removed reversals from Mount.  When Mount reverses offset after a guide, update the EqApp so it's clear where next offset will take it. 
2022-05-02: Done - Fix DiskAngleOffset calc to use +180
2022-05-02: Done - Coordinate Current Position and Arm Angle once a reference is "Marked".
2022-04-20: Done - Siderial location of Arm from current siderial time and Arm Angle.  
2022-04-20: Done - Current time and date to Siderial time straight above.
2022-04-09: Done, added to Title line - Add MountState indicator to GUideDataBlock and EqGuide Guide View. 
2022-04-08: Done - Stub in tab view with dummy focus page, to aid in top level UI layout.
2022-04-08: Done - Get RocketMount and EqGuide working with Direct offset or TargetOffset modes.
2022-04-06: Decide on file format for angles.  DMS, Float, or Double.
   Done - Use Int HM(Seconds Optionsal) for Right Ascension and DM(Seconds Optional) for Declination.  Internally, everything is decimal Float32.
2022-04-06: Decide on basic page layout.  Main with command buttions, offset inputs (absolute, or target), current position (absolute or target)
2022-03-01: Done - Command flow from EqGuide to RocketMount.  Initial use to turn on and off the flow of Az data.  Only flow it while parameter display view is active.  
    Decided to use Notify for data from RocketMount to EqGuide.  Mount is always writing if BLE connection established.  Really, BLE connection establishment is regulating the flow of data. Commands only flow from EqGuide on button presses.  Only commands at this time are set absolute offset (just move this much), and set relative offset (Mark reference, then move this much).  For now, all movement initiated from hardware pendant, so hardwired stop button is always handy. 
2022-03-01: Initial Data from from RocketMount.cpp to EqGuide. Start with RA count.  Figure out how to update at desired freq, independent of how frequently it updates in RocketMount.  
2022-03-01: Done - Initial BLE connection - OK - calling from onAppear.  It should init once, and not every time that view appears.  Need to move the init call to an applicaiton level init. Done - moved into EqGuideApp.
