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

local portName      = "COM6"
local on            = pubFTI.onOffState.ON
local off           = pubFTI.onOffState.OFF
local isInteractive = false

print('fabian-regression-hfo-single-limb-test: (' .. os.date() ..  ')')

local function testNCPAP()
    print('Test Manual Breath in NCPAP mode:')
	
    print('------------- step 11 ---------------')
    ft.setVentMode(pubFTI.ventMode.NCPAP)
    ft.setCPAP__mbar(5) 
    ft.setPManuel__mbar(15)
    ft.delay_sec(10)
    
    print('------------- step 12 ---------------')
    ft.setManBreathRunning(on)
    ft.delay_sec(3)
    
    print('------------- step 13 ---------------')
    local wavePres15 = ft.getWave(1)
    ft.setManBreathRunning(off)
	local wavePres5 = ft.getWave(1)
	verify.EXPECT_EQ_SET(wavePres15.Pressure, 15, pubFTI.pressureTolerance__cmH2O)
	verify.EXPECT_EQ_SET(wavePres5.Pressure, 5, pubFTI.pressureTolerance__cmH2O)
	
    print('------------- step 14 ---------------')
    for i = 1, 6 do
        ft.setManBreathRunning(on)
        ft.delay_sec(1)
        if i == 1 then 
        print('------------- step 15 ---------------')
         end
		verify.EXPECT_EQ_SET(ft.getWave(10).Pressure, 15, pubFTI.pressureTolerance__cmH2O)
        ft.setManBreathRunning(off)
        ft.delay_sec(5)
		verify.EXPECT_EQ_SET(ft.getWave(10).Pressure, 5, pubFTI.pressureTolerance__cmH2O)
    end
	
	print("NCPAP test PASSED") 
end

local function testO2Therapy()
    print('Test Flow in O2 Therapy mode:')
    print('------------- step 16 ---------------')
    ft.setVentMode(pubFTI.ventMode.O2Therapy)
    ft.setTherapyFlow__lpm(10)
    
    print('------------- step 17 ---------------')
    ft.delay_sec(30)
    
    print('------------- step 18 ---------------')
    verify.EXPECT_EQ(ft.getBTB().expFlow, 10, pubFTI.flowTolerance__lpm)
    verify.EXPECT_EQ_SET(ft.getWave(10).Pressure , 8, pubFTI.pressureTolerance__cmH2O)
    verify.EXPECT_EQ_SET(ft.getWave(10).Pressure , 8, pubFTI.pressureTolerance__cmH2O)

	print("02 Therapy test PASSED")
end

local function testDUOPAP()
    print('Test Waveform Pressure and Monitor Pressure in DUOPAP mode:')
    print('------------- step 19 ---------------')
    local isPEEP_5_mBar = false
    ft.setVentMode(pubFTI.ventMode.DUOPAP)
    ft.setCPAP__mbar(5)
    --no pduo 
    ft.setITime__sec(0.5)
    ft.setBPM__bpm(40) 
    
    print('------------- step 20 ---------------')
    ft.delay_sec(30) 
    
    print('------------- step 21 ---------------')
	if isInteractive then
        print('INTERACTIVE: Check that no active alarms are active.')
	    pass = utility.promptYesNoInput()
	    utility.checkToContinue(pass)
	end
    verify.EXPECT_EQ(ft.getBTB().PEEP, 5, pubFTI.pressureTolerance__cmH2O)
	verify.EXPECT_EQ(ft.getBTB().peakPressure, 15, pubFTI.pressureTolerance__cmH2O)
	if isInteractive then  
		print('------------- step 103 ---------------')
		ft.setITime__sec(0.15)
        print('INTERACTIVE: Check that I-Time says "end of range" under the value.')
	    pass = utility.promptYesNoInput()
	    utility.checkToContinue(pass)
	    print('------------- step 104 ---------------')
	    ft.setBPM__bpm(2) 
	    ft.setITime__sec(15)
        print('INTERACTIVE: Check that T-HIGH says "end of range" under the value.')
	    pass = utility.promptYesNoInput()
	    utility.checkToContinue(pass)
	    print('------------- step 105 ---------------')
	    ft.setITime__sec(0.15)
	    print('------------- step 106 ---------------')
        print('INTERACTIVE: Check that Frequency says "end of range" under the value.')
	    pass = utility.promptYesNoInput()
	    utility.checkToContinue(pass)
	    print('------------- step 107 ---------------')
	    ft.setBPM__bpm(60) 
        print('INTERACTIVE: Check that Frequency says "end of range" under the value.')
	    utility.pass = promptYesNoInput()
	   utility. checkToContinue(pass)
	end
	print("DUOPAP test PASSED")
end


---------------------------------------------------------------------
-- function call
---------------------------------------------------------------------
ft.openCOM(portName)
ft.initalizeVent()
testNCPAP()
testO2Therapy()
testDUOPAP()


ft.closeCOM()