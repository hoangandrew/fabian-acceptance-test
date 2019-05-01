------------------------------------------------------------------------------
-- (c) Copyright 2019 Vyaire Medical, or one of its subsidiaries.
--     All Rights Reserved.
------------------------------------------------------------------------------
-- Tests fabian Terminal Interface library
------------------------------------------------------------------------------

ft     = require "fabian-Terminal"
pubFTI = require "FTI-Public-Define"
verify = require "verify"

local portName = "COM6"
local on = pubFTI.onOffState.ON
local off = pubFTI.onOffState.OFF

ft.openCOM(portName)

print('fabian-regression-hfo-single-limb-test: ')

ft.initalizeVent()
local PressureTolerance = { absolute = 2, percent = 0}
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
    local wave = ft.getWave(1)
    ft.setManBreathRunning(off)
	verify.EXPECT_EQ_SET(15, wave.Pressure, PressureTolerance)
	
	--[[
    print('------------- step 14 ---------------')
    for i = 1, 6 do
        ft.setManBreathRunning(on)
        ft.delay_sec(1)
        if i == 1 then 
        print('------------- step 15 ---------------')
        end
        if (isManBreath_15_mBar ~= true and fr.pressFromContWave__mbar(14,16)) then 
            isManBreath_15_mBar = true
        end
        ft.setManBreathRunning(off)
        if (isPressure_5_mBar ~= true) then 
            isPressure_5_mBar = fr.pressFromContWave__mbar(4,6)
               
        end
        ft.delay_sec(5)
    end
    verify.EXPECT_TRUE(isPressure_5_mBar, " pressure was not 5 mBar")
    verify.EXPECT_TRUE(isManBreath_15_mBar, " Manuel breath was not 15 mBar")
	print("NCPAP test PASSED") ]]
end

local function testO2Therapy()
    print('Test Flow in O2 Therapy mode:')
    print('------------- step 16 ---------------')
    ft.setVentMode(pubFTI.ventMode.O2Therapy)
    ft.setTherapyFlow__lpm(10)
    
    print('------------- step 17 ---------------')
    ft.delay_sec(30)
    
    print('------------- step 18 ---------------')
	 local BTBflow10_Lpm = ft.getBTB().expFlow
	 local wave = ft.getWave(1)
    verify.EXPECT_COMPARE(10, BTBflow10_Lpm , pubFTI.flowTolerance__lpm.Abs + 10 * pubFTI.flowTolerance__lpm.percent)
    verify.EXPECT_COMPARE(10, WavePress10_Lpm[1].Pressure , pubFTI.flowTolerance__lpm.Abs + 10 * pubFTI.flowTolerance__lpm.percent)
    verify.EXPECT_COMPARE_ALL(10, wave.Pressure , pubFTI.flowTolerance__lpm)

	print("02 Therapy test PASSED")
end

local function testDUOPAPWave()
    local pressure__mBar = ft.getWave(100)
	for i = 0, 100 do 
	    if pressure__mBar >= pubFTI.flowTolerance__lpm.Abs + 5 * pubFTI.flowTolerance__lpm.percent then
	       pressure5Min__mBar = true
		 end
		 if pressure5Min__mBar == true and 
		    pressure__mBar <= pubFTI.flowTolerance__lpm.Abs + 16 * pubFTI.flowTolerance__lpm.percent then
	         return true
	    end
     end
	 
	 EXPECT_COMPARE_ALL(ft.getWave(100))
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
  --  ft.delay_sec(30) 
    
    print('------------- step 21 ---------------')
    IsPIP_15_mBar = ft.getBTB().peakPressure
    isPEEP_5_mBar = ft.getBTB().PEEP
    -- need verify pressure waveform
	verify.EXPECT_TRUE(testDUOPAPWave, "Expecting Pressure to have minimum 5 and maximum 16")
    -- need verify alarm activation
    verify.EXPECT_COMPARE(5, isPEEP_5_mBar, 1)
	verify.EXPECT_COMPARE(15, IsPIP_15_mBar,1)
	print("DUOPAP test PASSED")
end


---------------------------------------------------------------------
-- function call
---------------------------------------------------------------------
testNCPAP()
--testO2Therapy()
--testDUOPAP()

ft.closeCOM()