------------------------------------------------------------------------------
-- (c) Copyright 2019 Vyaire Medical, or one of its subsidiaries.
--     All Rights Reserved.
------------------------------------------------------------------------------
-- Tests fabian Terminal Interface library
------------------------------------------------------------------------------

ft = require "fabian-Terminal"
fr = require "fabian-regression-Define"
pubFTI = require "FTI-Public-Define"
local portName = "COM6"

ft.openCOM(portName)










--[[
----------- step 22 ---------------
--Connect the dual limb setup.
----------- step 23 ---------------
local pressure_5, Pmean_5 = nil
ft.setVentMode(6)
ft.setFlowMin__lpm(5)
ft.setCPAP__mbar(5) 
ft.setPManuel__mbar(15)
ft.setBackup(0)
----------- step 24 ---------------
--Decrease the low volume alarm threshold.
----------- step 25 ---------------
ft.delay_sec(30)
----------- step 26 ---------------
--CPAP is a constant value of 5 mbar.
pressure_5 = fr.pressFromContWave(3,7)
--P mean value should be approximately 5 mbar.
Pmean_5 = fr.meanPressFromContBTB(3,7)
if (pressure_5 and Pmean_5) then print("PASS step 22-26") else print ("FAILED") end
]]
--[[
----------- step 27 ---------------
ft.setBackup(5)
----------- step 28 ---------------
--Confirm on the graph that 5 backup breaths are periodically occurring.
--Confirm that the peak pressure shown on the graph during the breaths is approximately 15 mbar.
--Confirm that the ‘Backup Active’ alarm is shown while the backup breaths are occurring.
----------- step 28 ---------------
--Simulate spontaneous breaths by quickly pulling and releasing the nub on the test lung at least once a second. 
--
----------- step 23 - 32 ---------------
------- step 24 cannot be done ---------
ft.setVentMode(6)
ft.setFlowMin(5)
ft.setCPAP(5) 
ft.setPManuel(15)
ft.setBackup(0)
ft.delay_sec(2)
ft.setBackup(5)
ft.delay_sec(5)
for i = 1, 3 do
	ft.setManBreathRunning(1)
	ft.setManBreathRunning(0)
end
----------------------------------------
----------- step 33 - 29 ---------------

--ft.setVentMode(8)
--ft.setPeep(4)
--ft.setPInsPressure(14)
--ft.setBPM(30)

----------------------------------------
----------- step 36 - 37 ---------------
ft.setVentMode(1)
ft.setIFlow(8)
ft.setPeep(5)
ft.setPInsPressure(20)
ft.setBPM(30)
ft.setITime(1)
ft.setO2(21)
ft.setEFlow(8)
ft.delay_sec(30)


----------------------------------------
----------- step 41 - 42 ---------------
ft.setVentMode(2)
ft.setIFlow(10)
ft.setPeep(5)
ft.setPInsPressure(20)
ft.setBPM(30)
ft.setITime(1)
ft.setTrigger(1)
ft.setO2(21)
ft.setEFlow(8)
ft.delay_sec(30)
]]


ft.closeCOM()