# Meanings of Standard Terms

## PierMode
When PierMode is .east  (HA = LST-RA)
  - The target is on west. HA `>=` 0  
  - I define the HA=0 (RA=LST) case 0 or 180 edge cases as west targets
  - Pier is on east for North/West quadrant targets
  - Pier is on west for South/West quadrant targets
When PierMode is .west
  - The target is on the east, HA `<` 0
  - Pier is on west for North/East quadrant targets
  - Pier is on east for South/East quadrant targets
Initially PierMode is .unknown
  - RA of where telescope is pointing is .unknown
  - Pier position is .unknown until a Mark or Manual GoTo
  - arbitrarily use .east calculations Manual for N/S/E/W pointing
Only set to after MarkTarget, GoToTarget, GoToHome, GoToEast
  - Manual Mode GoTo Home or EastPier are both PierMode.east with HA=(LST-RA) = 0
  - When an eastern target (tracked in PierMode.west) tracks past LST to become a
    western target, the mount will not automatically switch to PierMode.east
    In that case, the mount can run to pierDeg hardware limit near -95º

## Hour Angle 
Hour Angle (ha) is negative east of the LST and positive west of LST
  ha = LST - ra
  ha = -1.2:  Coordinate.ra to east will be on LST in 1.2 hours
  ha = +1.3:  Coordinate.ra to west was on LST 1.3 hours ago
  
## Alt/Az - a.k.a Az/El
Az often represented as β in text
  0 `<` Az `<` 360
  Az measured on ground plane at observation site.
  Az measured from north, clockwise is positive
    Az = 0 north
    Az = 90 east
    Az = 180 south
    Az = 270 West
El often represented as el in text (aka Alt)
  -90 `<` El `<` 90
  El = 0 at local Horizon
  El = 90 at zenith
  El ranges from 0 to 90 for objects above horizon
  El ranges from 0 to -90 for objects below horizon
  if |El| > 90, Flip Az and El (Az+=180, El>0 ? El = 180-El : El = -180-El )
