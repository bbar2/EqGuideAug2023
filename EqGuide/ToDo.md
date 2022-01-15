Can I write freeform text in here.  Apparently yes.
Do I get spel checking.  No.

# Decisions
1. file format for angles.  DMS, Float, or Double.
2. basic page layout.  Main with command buttions, offset inputs (absolute, or target), current position (absolute or target)
3. Include DMS step buttons?

#  Data to Do's
1. Create json file with target offsets.
2. 

# Other Items
1. This is a Mark Down file. What are formating options in md files? 
2. Create Icon - move to Assets
3. Initial BLE connection - OK - calling from onAppear.  It should init once, and not every time that view appears.  Need to move the init call to an applicaiton level init. 
4. Initial Data from from RocketMount.cpp to EqGuide. Start with RA count.  Figure out how to update at desired freq, independent of how frequently it updates in RocketMount.  
5. Command flow from EqGuide to RocketMount.  Initial use to turn on and off the flow of Az data.  Only flow it while parameter display view is active.

