# Reference frame definitions 

## Local Reference Frame 
  Right Handed Coordinate System
  Local_X Level North
  Local_Y Level West
  Local_Z Up Opposite Gravity

## Mount Reference Frame 
  Local Reference Frame rotated theta around Local_Y to point to north celestial pole, near Polaris
  Mount_X rotated around Local_Y to north celestial pole.  theta = -(local latitude)
  Mount_Y level out left toward west, remains aligned with Local_Y
  Mount_Z rotated around Local_Y southward to equitorial

## Pier Reference Frame
  Mount reference frame rotated by phi around Mount_X
  Pier_X remains aligned with Mount_X
  Pier_Y and Pier_Z rotate around Mount_X,
  X rotation (phi) aligns target_RA, and is function of HA = target_RA - LST

## Telescope Reference Frame
  Pier Reference frame rotated by psi around Pier_Z axis.
  Tele_X forward out optical axis of telescope
  Tele_Y out left side of telescope (left defined when aligned with Local frame)
  Tele_Z remains aligned with Pier_Z. Out top of telescope
  Z rotation (psi) aligns target DEC, and is function of RA, LST and DEC.

# Rotation and Mount angles

Mount hardware order of rotations, defined by cascaded hardware design:
  theta: +CW pitch around Local_Y/Mount_Y to point to Polaris (theta = -Latitude)
  phi: +CW roll around Mount_X/Pier_X to align RA (phi = -pierDeg)
  psi: +CW yaw around Pier_Z/Tele_Z to align DEC (psi = 90 - diskDeg)

Mount pier angle (pierDeg) rotates in Right Ascension, around Mount_X/Pier_X
 Increases CCW looking out Mount_X, away from mount, toward polaris.
  I suspect the origin of this CCW is the westward tracking advance.
  pierDeg is:
    +90º when pier is horizontal on west side
    -90º when pier is horizontal on east side
    0 when pier is vertical
  -180 <= pierDeg < +180.  Add or subtract 360 to keep in this range.
 Pier angle range of motion mechanically limited to +- ~95º
 phi = -pierDeg; // due to CCW direction of pierDeg.

 Mount Disk angle (diskDeg) rotates in Declination, around Pier_Z/Tele_Z
 + is CCW looking up from bottom of disk.
 diskDeg is:
  +90 pointing at north end of pier
  -90 pointing at south end of pier
    0 pointing to west side of pier
-180 <= diskDeg < 180. Add or subtract 360 to keep in this range.
Disk angle is not mechanically limited.  Can do 360's all day.
psi = (90 - diskDeg); // Due to 90 degree offset and CCW direction of diskDeg.

LST runs North to South and is always straight up f(time, longitude)
  0 <= LST < 360º (0 <= LST < 24 hr)
RA is fixed to celstial sphere
  0 <= RA < 360º (0 <= RA < 24 hr)
  increases CW looking at Polaris
Hour Angle = ha = LST-RA
  0 <= ha < 360 (24hr)
  I prefer to map it to -180 (-12hr) <= ha < 180 (12hr) so
    ha < 0 for targets to east
    ha > 0 for targets to west
    |ha| <= 90deg (6hr) for targets above horizon
  increases CCW looking at Polaris

DEC is fixed to celestial sphere
  +90 at north pole
    0 at equator
  -90 at south pole
  -90 <= DEC <= +90
   if |DEC| == 90, RA rotates FOV but does not change where telescope is pointing

 RA/DEC to pierDeg/diskDeg mapping depends on target's side of pier
 determined by (RA-LST)
   If target is west of LST use normal declination (NW or SW Quadrants)
     180 <= (RA-LST) <= 360
     PierMode = .east
     (RA-LST) = -90 - pierDeg
     pierDeg = -90 - (RA-LST) = LST - 90 - RA
     RA = LST - 90 - pierDeg
     Note that pierDeg decreases as RA increases.
     This fits since pierDeg increases CCW and RA increases CW.
     diskDeg = DEC   //-90 <= diskDeg <= +90
     DEC = diskDeg
     |diskDeg| <= 90
 If target is east of LST use flipped declination (NE or SE Quadrant)
     0 < (RA-LST) < 180
     PierMode = .west
     (RA-LST) = 90 - pierDeg
     pierDeg = 90 - (RA-LST) = LST + 90 - RA
     RA = LST + 90 - pierDeg
     diskDeg = 180 - DEC
     DEC = 180 - diskDeg
     |diskDeg| > 90
  After mapping, always limit:
    -180 <= pierDeg < 180
    -180 <= diskDeg < 180
    0 <= (RA-LST) < 360
    -90 <= DEC <= +90

 TODO: consider adding ~2 degree padding on pier declination flip.
 Upgrade: For eastern targets near LST, use normal declination to prevent
   westward tracking from quickly running into 95º hardware limit
   - If eastern target is within padº of vertical, start with pier on east.
   - Detect with (RA-LST) < padº, or (RA-LST) < (180º+pad)
   - Do I need pierDeg/diskDeg to RA/DEC calcs to have opposite logic?

# Pier Positions

## HA is LST-RA.  
  - My code frequently uses RA-LST.  
  - Try to update code to use HA.

## HOME Position:
  - pier Vertical: pierDeg = 0
  - disk points West: diskDeg = 0.  Supports focus motor setup.
  - x axis now points west.  y axis now points south.
  - Since dskDeg < 90, use DecMode.normal angle mapping
    (RA-LST) = -90º - pierDeg = -90º;  RA = LST - 90º
    DEC = dskDeg = 0º

## EAST PIER Position: (Not to be confused with PierMode East)
  - pier Horizontal with mount on east side of pier:  pierDeg = -90º
  - disk points up at LST. diskDeg = 0.
  - This is edge case in raDecToMountAngles since LST can be viewed from either:
    -- pierDeg = -90, diskDeg = 0, DecMode.normal, pier on east
    -- pierDeg = 90, diskDeg = -180, DecMode.flipped, pier on West
    - added test in raDecToMountAngles to force this to DecMode.normal
  - x axis points up at equitorial plane
  - y axis points at north pole
  - z axis is horizontal
  - since dskDeg < 90, use DecMode.normal angle mapping
    (RA-LST) = -90º - pierDeg = -90º - (-90º) = 0;  RA = LST
    DEC = dskDeg = 0º
