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

local function testASSIST()
    print('Test ASSIST mode:')
	ft.setVentMode(pubFTI.ventMode.SIPPV)
    ft.setIFlow__lpm(8)
	ft.setITime__sec(1)
	ft.setPeep__mbar(5)
	ft.setPInsPressure__mbar(20)
	ft.setBPM__bpm(30)
	ft.setVGuarantee__ml(2)
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
	verify.EXPECT_EQ(ft.getBTBAVG().inspMandTidalVolume, 2, pubFTI.pressureTolerance__cmH2O)
	ft.setStateVGuarantee(0)

	print("ASSIST test PASSED")
end

ft.openCOM(portName)
ft.initalizeVent()
testASSIST()
ft.closeCOM()