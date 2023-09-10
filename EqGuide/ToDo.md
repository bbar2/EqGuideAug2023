Can I write freeform text in here.  Apparently yes.
Do I get spel checking.  No.
This is a Mark Down file. What are formating options in md files? 
  # makes a title

# ToDo - Date put on list. Top Priority at top of list. 

2023-09-09: Get rid of white stuff on top of LocationOptionSheet.  
2023-09-09: Change color of Use Toggle button on LocationOptionSheet. 
2023-09-09: If pointingKnowledge == .none, use Saddle XL to set first guess with calculated angles.  Can still improve with a East or Home.
2023-09-04: Add Time offset driven by alt time in LocationOptionSheet.
2023-08-31: Why is Alt/Az moving when not Tracking, and PointingKnowledge.none ?
2023-08-29: Why are PierOffset's 15, 63, 31.  Seems like should be multiples of 16.
2023-08-31: Why HW View, XL Rots, not updating on first display?  Must jump to Focus View, then back to get them updating.  The source accels are updating.
2023-08-29: If tracking, stop if armAngle > 93ish.  Don't track into rail.  Simply issuing a GotoTarget will do a flip. Do that automatically????
2023-08-28: Why do GoHome and GoEast not end on the mark on first try?
2023-07-02: Should a Reset command change the pointing knowledge to none?
2023-06-17: Add a 30 degree RA button to help with Polemaster alignment operation.
2023-06-17: Hardware Red button, should also neutralize ios move commands. Directly, and probably through the data block sent to ios.
2023-05-27: Shutdown should be more orderly.  Close BLE connections, then shutdown.
2022-05-07: Add filters to TargetList.  At least filter by constellation and type
2022-05-07: Add ability to see description for each TargetList Item.  Impacts how UI works.
2022-05-05: LST should run, even if BLE not connected.  Probably own timer.
2022-10-10: Add time varying coordinates for Planets - or just enter them manually at show time. 

# Done Items - Newest on top.  Date item completed.

2023-09-09: Done.  Did this in onAppear and onDissapear for relevant tabs - Focus - Only auto disconnect after first Mark. Leave a disconnect button.  I think I can use PierMode.unknown to detect this.
2023-09-09: Done. went with the issue connect approach - Manual - Home/EastPier either disable if no Focus and Pier BLE connection, or issue connects to both before executing Home/EastPier operations.  Maybe, disable if no Pier, and issue Focus connect if not connected.
2023-09-09: Done - Move XlToAngle calculations from HardwareView into MountModel.
2023-09-09: Done - Disable GoToTarget if pointingKnowledge == none
2023-09-09: Done - Check and clamp XlAngle calcs to avoid NaN.
2023-06-18: Done - Created DmInputView and added init(d,m) to Dms type. - Add Lat/Long to hardware view, with option for manual entry. 
2023-06-08: Hardware - Done - Used appDisabledColor.  Blend BLE Yellow indicators into the accel/angle table lables, and maybe columns.  Columns might be too much yellow.
2023-08-30: Done - GoTo Target (and Mark Target) should resume Tracking.
2023-08-30: Reject since HA is now a viewMode and it combines LST and RA. - Consider moving LST to center of status bar.
2023-08-30: Done - Fix Pier East/West display.
2023-08-28: Done - HourAngle - add option to display HA instead of RA.  HA = LST-RA
2023-08-24: Done - Decide on colors for Gray/Disabled, Yellow/NoBle, Red/Good.  When to use yellow vs gray.  Use the orange from LST app.
2023-08-24: GuideCommands can be lost.  Need a handshake or queue approach. Used BLEWrite (withResponse implied) property on the Characteristic for GuideCommandData
2022-08-23: GUI reconfigure - No functional change to GuideMount
  New main Guide with: 
    done - BLE Link indication for all three BLE devices - for status display
    done - East/West Pier indicator
    done - AZ/EL conversion
    Done - Current RA/DEC (Yellow from angle, Red from Ref)
    Done - LST, Lat, Long
    Done - Target RA/DEC - select and swap controls
    Done - Ref RA/DEC - select control
    Done - Pause Guiding Control
    Done - Swap and Set Target and Ref Control which transmits to mount
2023-07-24: Done - Mount BLE reconnects. Make Pier and Focus do it too.
2023-07-24: NO - Mount does this with counts:  While guiding to a target, Pause Tracking to improve accuracy.
2023-07-02: Done - Add a way to select the fixed angle refPierVert/East/West reference points. 
2023-07-02: Done - When I Set East Pier, it's only correct for an instant. Running making the reference error increase.  
2023-07-02: Done - Targ mode not working as expected. Ref/Targ mode works well.
2023-07-02: Done - it was the straight up is west thing.  Added test for (RA-LST) -- 0. After GOTO EastPier, PierDeg should be -90 and it's +90
2023-07-02: Done - Focus - Connect and Start BLE. Remove all XL data stuff from this page.
2023-07-02: Done - Review/Update reference confidence:  updateOffsetsTo(reference:) should update confidence to estimated value.  MarkRef should change to highest value. 
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
