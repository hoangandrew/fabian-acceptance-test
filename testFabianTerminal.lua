------------------------------------------------------------------------------
-- (c) Copyright 2019 Vyaire Medical, or one of its subsidiaries.
--     All Rights Reserved.
------------------------------------------------------------------------------
-- Tests fabian Terminal Interface library
------------------------------------------------------------------------------

ft = require "fabianTerminal"

ft.openCOM()

--ft.setBPM(16)
--ft.setIFlow(10)
--ft.setO2(21)
--ft.setPeep(4)
--ft.setPInsPressure(14)
--ft.setStateVGuarantee(2)
--ft.setStateVLimit(1)
--ft.setVetRunState(1)
--ft.setVentMode(1)
--ft.setPSV(6)
--ft.setStatePressureRiseControl(0)
--ft.setStateBodyWeightRange(2) --1 or 2
--ft.setManBreathRunning(1)
--ft.setIERatioHFO(0) --0=3 1=2 2=3
--ft.setHFOFreqRec(95) --once you get to 60 we can only do multi of 2 i.e 120 180 ect
--ft.setHFOFlow(20)
--ft.setLeakCompensation(2) 
--ft.setHFOAmp(15)
--ft.setHFOAmpMax(20)
--ft.setHFOFreq(10)
--ft.setEFlow(5)
--ft.setRiseTime(2) 
--ft.setITime(1)
--ft.setETime(4)
--ft.setHFOPMean(9)
--ft.setHFOPMeanRec(9)
--ft.setVLimit(6)
--ft.setVGuarantee(3)
--ft.setAbortCriterionPSV(4)--in psv menu
--ft.setTherapyFlow(4)
--ft.setTrigger(4)
--ft.setFlowMin(8)
--ft.setCPAP(4) 
--ft.setPManuel(12)
--ft.setBackup(4)
--ft.setITimeRec(3)
--ft.setO2Flush(26)


----below can not live update--------
--ft.setSPO2Low(0) 
--ft.setSPO2High(99) 
--ft.setFIO2Low(21) 
--ft.setFIO2High(100) 
--------------------------------------
--ft.setStatePrico(0)


----------Get Values----------
--ft.getBTB()
--ft.getContinousBTB(1)
--ft.getAVG()
--ft.getContinousAVG(10)
--ft.getContinousWaveData(15)
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
--print(ft.getCPAP())
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