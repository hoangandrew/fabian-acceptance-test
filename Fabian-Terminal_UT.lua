------------------------------------------------------------------------------
-- (c) Copyright 2019 Vyaire Medical, or one of its subsidiaries.
--     All Rights Reserved.
------------------------------------------------------------------------------
-- Tests fabian Terminal Interface library
------------------------------------------------------------------------------

ft = require "fabian-Terminal"
pubFTI = require "FTI-Public-Define"
verify = require "verify"
local portName = "COM6"

ft.openCOM(portName)
--print(ft.getContWave().Pressure)
--[[
 ft.setIFlow__lpm(8)
	ft.setITime__sec(1)
	ft.setPeep__mbar(5)
	ft.setPInsPressure__mbar(20)
	ft.setETime__sec(8) --e-time must be before freq, not sure why
	ft.setBPM__bpm(30)
	ft.setVGuarantee__ml(2)
	ft.setO2(30)
	ft.delay_sec(3)
	ft.setStateVGuarantee(0)
]]
--ft.setBPM(16)
--ft.setIFlow__lpm(12)
--ft.setO2(40)
--ft.setPeep__mbar(4)
--ft.setPInsPressure__mbar(12)
--ft.setStateVGuarantee(1)
--ft.setStateVLimit(1)
--ft.setVetRunState(1)
--ft.setVentMode(pubFTI.ventMode.NCPAP)
--ft.setPSV__mbar(6)
--ft.setStatePressureRiseControl(0) --0=i-flow 1=risetime 
--ft.setStateBodyWeightRange(0) --1 or 2
--ft.setManBreathRunning(1)
--ft.setIERatioHFO(0) --0=3 1=2 2=3
--ft.setHFOFreqRec__hz(239) --once you get to 60 we can only do multi of 2 i.e 120 180 ect
--ft.setHFOFlow__lpm(15)
--ft.setLeakCompensation(1) 
--ft.setHFOAmp__mbar(21)
--ft.setHFOAmpMax__mbar(25)
--ft.setHFOFreq__hz(14)
--ft.setEFlow__lpm(5)
--ft.setRiseTime__sec(.6) 
--ft.setITime__sec(1.1)
--ft.setETime__sec(5)
--ft.setHFOPMean__mbar(8)
--ft.setHFOPMeanRec__mbar(15)
--ft.setVLimit__ml(6)
--ft.setVGuarantee__ml(4)
--ft.setAbortCriterionPSV__per(5)--in psv menu
--ft.setTherapyFlow__lpm(5)
--ft.setTrigger(3)                                         
--ft.setFlowMin__lpm(9) --cpap
ft.setCPAP__mbar(6) 
--ft.setPManuel__mbar(12)
--ft.setBackup(0)
--ft.setITimeRec__sec(10)
--ft.setO2Flush(26)


----below can not live update--------
--ft.setSPO2Low(10) 
--ft.setSPO2High(98) 
--ft.setFIO2Low(21) 
--ft.setFIO2High(100) 
--------------------------------------
--ft.setStatePrico(0)

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@
----------Get Values----------
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@

------------------------------
------ Breath to Breath ------
--[[
local breathData = ft.getBTB()
i = 0
 for k, v in pairs(breathData) do
	print(i.. " " .. k .. " = " .. v)
	i = i + 1
end
]]
------------------------------
------------------------------

------------------------------
-- Continuous Breath to Breath 
--[[
local breathData = ft.getContinousBTB()
for i = 0, 5 do
    for k, v in pairs(breathData) do
	    print(k .. " = " .. v)
    end
end
]]
------------------------------
------------------------------

--ft.getContinousBTB(1)

------------------------------
-- Breath to Breath Average --
--[[
local breathData = ft.getAVG()
 for k, v in pairs(breathData) do
	print(k .. " = " .. v)
end
]]
------------------------------
------------------------------

--ft.getContinousAVG(10)
--ft.getContinousWaveData(100)
------------------------------
-- Continuous Breath to Breath 
--[[
local breathData = ft.getContinousWaveData()
for i = 0, 1000 do
    for k, v in pairs(breathData) do
	    print(k .. " = " .. v)
    end
end
]]
------------------------------
------------------------------

--ft.getWaveData(10)
--print(ft.getVentMode())
--print(ft.getRunState())
--print(ft.getStateVLimit())
--print(ft.getStateVGuarentee())
--print(ft.getVentRange()) 
--print(ft.getIERatioHFO())
--print(ft.getManBreathRunning())
--print(ft.getPressureRiseControl())
--print(ft.getHFOFreqRec())
--print(ft.getHFOFlow())
--print(ft.getLeakCompensation())
--print(ft.getTriggerOption())
--ft.getFOTOscillationState() --*idk what this is*
--print(ft.getPInsPressure())
--print(ft.getPeep())
--print(ft.getPPSV())
--ft.getBPM() -- does not work as it should 
--print(ft.getHFOAmpl()) --value only changes once the hfo mode is selected
--print(ft.getHFOAmplMax())
--print(ft.getHFOFreq())
--print(ft.getO2())
--print(ft.getIFlow())
--print(ft.getEFlow())
--print(ft.getRiseTime()) --1 risetime / 0 i-flow
--print(ft.getITime())
--print(ft.getETime())
--print(ft.getHFOPMean())
--print(ft.getHFOPMeanRec())
--print(ft.getParamVLimit()) 
--print(ft.getParamVGuarantee())
--print(ft.getAbortCriterionPSV()) --psv

--print(ft.getTherapyFlow())
--print(ft.getTrigger())
--print(ft.getFlowMin())
print(ft.getCPAP())
--print(ft.getPManuel())
--print(ft.getBackup())
--print(ft.getITimeRec())--hfo
--print(ft.getETimeRec()) --*idk what this is*
--print(ft.getSPO2Low())
--print(ft.getSPO2High())
--print(ft.getFIO2Low()) --this does not match whats on the gui
--print(ft.getFIO2High())
--print(ft.getPRICO())




ft.closeCOM()