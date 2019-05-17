------------------------------------------------------------------------------
-- (c) Copyright 2019 Vyaire Medical, or one of its subsidiaries.
--     All Rights Reserved.
------------------------------------------------------------------------------
-- Tests fabian Terminal Interface library
------------------------------------------------------------------------------

ft      = require "fabian-Terminal"
pubFTI  = require "FTI-Public-Define"
verify  = require "verify"
utility = require "utility"

local portName = "COM6"
local on       = pubFTI.onOffState.ON
local off      = pubFTI.onOffState.OFF

local function testCMV()
    print('Test CMV mode:')
	ft.setVentMode(pubFTI.ventMode.IPPV)
    ft.setIFlow__lpm(8)
	ft.setITime__sec(1)
	ft.setPeep__mbar(5)
	ft.setPInsPressure__mbar(20)
	ft.setETime__sec(8) --e-time must be before freq, not sure why
	ft.setBPM__bpm(30)
	ft.setVGuarantee__ml(10)
	ft.setO2(30)
	ft.delay_sec(3)
	ft.setStateVGuarantee(0)
	
	--PRS-0061
	ft.setManBreathRunning(1)
	ft.delay_sec(3)
	verify.EXPECT_EQ_SET(ft.getWave(10).Pressure, 20, pubFTI.pressureTolerance__cmH2O)
	ft.setManBreathRunning(0)
	ft.delay_sec(30)

	verify.EXPECT_EQ(ft.getBTBAVG().respiratoryRate, 30, pubFTI.rateTolerance__bpm)
	--PRS-0049
	verify.EXPECT_EQ(ft.getBTB().PEEP, 5, pubFTI.pressureTolerance__cmH2O)
	verify.EXPECT_EQ(ft.getBTB().peakPressure, 20, pubFTI.pressureTolerance__cmH2O)
	verify.EXPECT_EQ(ft.getBTB().FiO2, 30, pubFTI.oxygen)
	
	--PRS-0039
	ft.setStateVGuarantee(1)
	ft.delay_sec(20)
	verify.EXPECT_EQ(ft.getBTBAVG().inspMandTidalVolume, 10, pubFTI.pressureTolerance__cmH2O)
	ft.setStateVGuarantee(0)
	
	--[[
	ft.setPeep__mbar(3)
	ft.setPInsPressure__mbar(6)
	ft.setBPM__bpm(11)
	ft.setO2(21)
	ft.delay_sec(90)
	
	verify.EXPECT_EQ(ft.getBTBAVG().respiratoryRate, 11, pubFTI.rateTolerance__bpm)
	--PRS-0049
	verify.EXPECT_EQ(ft.getBTB().PEEP, 1, pubFTI.pressureTolerance__cmH2O)
	verify.EXPECT_EQ(ft.getBTB().peakPressure, 4, pubFTI.pressureTolerance__cmH2O)
	verify.EXPECT_EQ(ft.getBTB().FiO2, 21, pubFTI.oxygen)
	
	ft.setPeep__mbar(13)
	ft.setPInsPressure__mbar(75)
	ft.setITime__sec(0.10)
	ft.setBPM__bpm(200)
	ft.setO2(100)
	ft.delay_sec(30)
	
	verify.EXPECT_EQ(ft.getBTBAVG().respiratoryRate, 200, pubFTI.rateTolerance__bpm)
	--PRS-0049
	verify.EXPECT_EQ(ft.getBTB().PEEP, 13, pubFTI.pressureTolerance__cmH2O)
	verify.EXPECT_EQ(ft.getBTB().peakPressure, 75, pubFTI.pressureTolerance__cmH2O) --how can we make this happen?
	verify.EXPECT_EQ(ft.getBTB().FiO2, 100, pubFTI.oxygen)
	]]

	
	
    print("CMV test PASSED")
end

ft.openCOM(portName)
ft.initalizeVent()
testCMV()
ft.closeCOM()