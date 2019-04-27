------------------------------------------------------------------------------
-- (c) Copyright 2019 Vyaire Medical, or one of its subsidiaries.
--     All Rights Reserved.
------------------------------------------------------------------------------
-- Tests fabian Terminal Interface library
------------------------------------------------------------------------------

ft     = require "fabian-Terminal"
fr     = require "fabian-measurement-response"
pubFTI = require "FTI-Public-Define"
verify = require "verify"

local portName = "COM6"
local on = pubFTI.onOffState.ON
local off = pubFTI.onOffState.OFF

ft.openCOM(portName)

print('fabian-regression-hfo-single-limb-test: ')

ft.initalizeVent()
print('------------- step 11 ---------------')
ft.setVentMode(pubFTI.ventMode.NCPAP)
ft.setCPAP__mbar(5) 
ft.setPManuel__mbar(15)
ft.delay_sec(10)

print('------------- step 12 ---------------')
ft.setManBreathRunning(on)
ft.delay_sec(3)

print('------------- step 13 ---------------')
local isPressure_15_mBar = fr.pressFromContWave(13, 17)
ft.setManBreathRunning(off)
verify.EXPECT_TRUE(isPressure_15_mBar, " pressure was not 15")

print('------------- step 14 ---------------')
local isManBreath_15_mBar = false
local isPressure_5_mBar = false
for i = 1, 6 do
    ft.setManBreathRunning(on)
    ft.delay_sec(1)
    if i == 1 then 
    print('------------- step 15 ---------------')
    end
    if (isManBreath_15_mBar ~= true and fr.pressFromContWave(14,16)) then 
        isManBreath_15_mBar = true
    end
    ft.setManBreathRunning(off)
    if (isPressure_5_mBar ~= true) then 
        isPressure_5_mBar = fr.pressFromContWave(4,6)
           
    end
    ft.delay_sec(5)
end
verify.EXPECT_TRUE(isPressure_5_mBar, " pressure was not 5 mBar")
verify.EXPECT_TRUE(isManBreath_15_mBar, " Manuel breath was not 15 mBar")

print('------------- step 16 ---------------')
local isFlow_10_Lpm = false
ft.setVentMode(pubFTI.ventMode.O2Therapy)
ft.setTherapyFlow__lpm(10)

print('------------- step 17 ---------------')
ft.delay_sec(30)

print('------------- step 18 ---------------')
isFlow_10_Lpm = fr.expFlowFromContBTB(9,11)
verify.EXPECT_TRUE(isFlow_10_Lpm, " flow was not 10 Lpm")

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
IsPIP_15_mBar = fr.peakPressFromContBTB(14,16)
isPEEP_5_mBar = fr.peepFromContBTB(4,6)
-- need verify pressure waveform
-- need verify alarm activation
verify.EXPECT_TRUE(isPEEP_5_mBar, " PEEP was not 5 mBar")
verify.EXPECT_TRUE(IsPIP_15_mBar, " PIP was not 15 mBar")

ft.closeCOM()