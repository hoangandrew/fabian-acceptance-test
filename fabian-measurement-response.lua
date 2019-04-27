------------------------------------------------------------------------------
-- (c) Copyright 2019 Vyaire Medical, or one of its subsidiaries.
--     All Rights Reserved.
------------------------------------------------------------------------------

pubFTI = require "FTI-Public-Define"
ft     = require "fabian-Terminal"

local function readExpectedValueFromContData(xContData,xStrName,xMin,xMax)
    local expectedValue = false
    for i = 0, 10 do 
        for k, v in pairs(xContData) do
    	    if (k == xStrName) then 
			    ft.printDebug(k .. " = " .. v)
    		    if (xMax == nil and xMin == v) then
    		     	 expectedValue = true
                     return expectedValue					 
    			elseif (xMax ~= nil and 
    					v >= xMin and 
    					v <= xMax) then		
    				 expectedValue = true
					return expectedValue
    			end
    		end
    		ft.printDebug(k .. " = " .. v)
        end
    end
    return expectedValue
end

local function pressFromContWave(xPressureMin, xPressureMax)
    return readExpectedValueFromContData(ft.getContinousWaveData(),"Pressure",xPressureMin,xPressureMax)
end

local function flowFromContWave(xFlowMin, xFlowMax)
    return readExpectedValueFromContData(ft.getContinousWaveData(),"Flow",xFlowMin,xFlowMax)
end

local function etCO2FromContWave(xETCO2Min, xETCO2Max)
    return readExpectedValueFromContData(ft.getContinousWaveData(),"etCO2",xETCO2Min,xETCO2Max)
end


local function modeFromContBTB(xModeMin, xModeMax)
    return readExpectedValueFromContData(ft.getContinousBTB(),"mode",xModeMin,xModeMax)
end

local function peakPressFromContBTB(xPeakPressMin, xPeakPressMax)
    return readExpectedValueFromContData(ft.getContinousBTB(),"peakPressure",xPeakPressMin,xPeakPressMax)
end

local function meanPressFromContBTB(xMeanPressMin, xMeanPressMax)
    return readExpectedValueFromContData(ft.getContinousBTB(),"meanPressure",xMeanPressMin,xMeanPressMax)
end

local function peepFromContBTB(xPeepMin, xPeepMax)
    return readExpectedValueFromContData(ft.getContinousBTB(),"PEEP",xPeepMin,xPeepMax)
end

local function dynamCompFromContBTB(xDynamCompMin, xDynamCompMax)
    return readExpectedValueFromContData(ft.getContinousBTB(),"dynamticCompliance",xDynamCompMin,xDynamCompMax)
end

local function overExtenFromContBTB(xOverExtenMin, xOverExtenMax)
    return readExpectedValueFromContData(ft.getContinousBTB(),"overExtension",xOverExtenMin,xOverExtenMax)
end

local function ventResFromContBTB(xVentResMin, xVentResMax)
    return readExpectedValueFromContData(ft.getContinousBTB(),"ventilaryResistance",xVentResMin,xVentResMax)
end

local function minVolFromContBTB(xMinVolMin, xMinVolMax)
    return readExpectedValueFromContData(ft.getContinousBTB(),"minuteVolume",xMinVolMin,xMinVolMax)
end

local function inspManTVFromContBTB(xInspManTVMin, xInspManTVMax)
    return readExpectedValueFromContData(ft.getContinousBTB(),"inspMandTidalVolume",xInspManTVMin,xInspManTVMax)
end

local function expManTVFromContBTB(xExpManTVMin, xExpManTVMax)
    return readExpectedValueFromContData(ft.getContinousBTB(),"expMandTidalVolume",xExpManTVMin,xExpManTVMax)
end

local function expManTVPatFromContBTB(xExpManTVPatMin, xExpManTVPatMax)
    return readExpectedValueFromContData(ft.getContinousBTB(),"expMandTVPatient",xExpManTVPatMin,xExpManTVPatMax)
end

local function hfoAmpFromContBTB(xHFOAmpMin, xHFOAmpMax)
    return readExpectedValueFromContData(ft.getContinousBTB(),"HFAmp",xHFOAmpMin,xHFOAmpMax)
end

local function hfoExpManTVFromContBTB(xhfoExpManTVMin, xhfoExpManTVMax)
    return readExpectedValueFromContData(ft.getContinousBTB(),"HFExpMandTidalVolume",xhfoExpManTVMin,xhfoExpManTVMax)
end

local function gasTranCoefFromContBTB(xGasTranCoefMin, xGasTranCoefMax)
    return readExpectedValueFromContData(ft.getContinousBTB(),"gasTransportCoefficient",xGasTranCoefMin,xGasTranCoefMax)
end

local function trigVolFlowFromContBTB(xTrigVolFlowMin, xTrigVolFlowMax)
    return readExpectedValueFromContData(ft.getContinousBTB(),"triggerVolumeFlow",xTrigVolFlowMin,xTrigVolFlowMax)
end

local function inspTimePSVFromContBTB(xInspTimePSVMin, xInspTimePSVMax)
    return readExpectedValueFromContData(ft.getContinousBTB(),"InspTimePSV",xInspTimePSVMin,xInspTimePSVMax)
end

local function SpO2FromContBTB(xSpO2Min, xSpO2Max)
    return readExpectedValueFromContData(ft.getContinousBTB(),"SpO2",xSpO2Min,xSpO2Max)
end

local function pulseRateFromContBTB(xPulseRateMin, xPulseRateMax)
    return readExpectedValueFromContData(ft.getContinousBTB(),"pulseRate",xPulseRateMin,xPulseRateMax)
end

local function perfIndexFromContBTB(xPerfIndexMin, xPerfIndexMax)
    return readExpectedValueFromContData(ft.getContinousBTB(),"perfusionIndex",xPerfIndexMin,xPerfIndexMax)
end

local function etCO2FromContBTB(xETCO2Min, xETCO2Max)
    return readExpectedValueFromContData(ft.getContinousBTB(),"etCO2",xETCO2Min,xETCO2Max)
end

local function respRateFromContBTB(xRespRateMin, xRespRateMax)
    return readExpectedValueFromContData(ft.getContinousBTB(),"respiratoryRate",xRespRateMin,xRespRateMax)
end

local function respRateETCO2ModFromContBTB(xRespRateETCO2ModMin, xRespRateETCO2ModMax)
    return readExpectedValueFromContData(ft.getContinousBTB(),"respiratoryRateETCO2Mod",xRespRateETCO2ModMin,xRespRateETCO2ModMax)
end

local function leakageFromContBTB(xLeakageMin, xLeakageMax)
    return readExpectedValueFromContData(ft.getContinousBTB(),"leakage",xLeakageMin,xLeakageMax)
end

local function hfoRateFromContBTB(xHFORateMin, xHFORateMax)
    return readExpectedValueFromContData(ft.getContinousBTB(),"HFRate",xHFORateMin,xHFORateMax)
end

local function shareMVRespFromContBTB(xShareMVRespMin, xShareMVRespMax)
    return readExpectedValueFromContData(ft.getContinousBTB(),"shareMVRespirator",xShareMVRespMin,xShareMVRespMax)
end

local function FiO2FromContBTB(xFiO2Min, xFiO2Max)
    return readExpectedValueFromContData(ft.getContinousBTB(),"FiO2",xFiO2Min,xFiO2Max)
end

local function inspFlowFromContBTB(xInspFlowMin, xInspFlowMax)
    return readExpectedValueFromContData(ft.getContinousBTB(),"inspFlow",xInspFlowMin,xInspFlowMax)
end

local function expFlowFromContBTB(xExpFlowMin, xExpFlowMax)
    return readExpectedValueFromContData(ft.getContinousBTB(),"expFlow",xExpFlowMin,xExpFlowMax)
end

function demFlowFromContBTB(xDemFlowMin, xDemFlowMax)
    return readExpectedValueFromContData(ft.getContinousBTB(),"demandFlow",xDemFlowMin,xDemFlowMax)
end

fr = {
    pressFromContWave           = pressFromContWave,
	flowFromContWave            = flowFromContWave,
	etCO2FromContWave           = etCO2FromContWave,
	modeFromContBTB             = modeFromContBTB,
	peakPressFromContBTB        = peakPressFromContBTB,
	meanPressFromContBTB        = meanPressFromContBTB,
	peepFromContBTB             = peepFromContBTB,
	dynamCompFromContBTB        = dynamCompFromContBTB,
	overExtenFromContBTB        = overExtenFromContBTB,
	ventResFromContBTB          = ventResFromContBTB,
	minVolFromContBTB           = minVolFromContBTB,
	inspManTVFromContBTB        = inspManTVFromContBTB,
	expManTVFromContBTB         = expManTVFromContBTB,
	expManTVPatFromContBTB      = expManTVPatFromContBTB,
	hfoAmpFromContBTB           = hfoAmpFromContBTB,
	hfoExpManTVFromContBTB      = hfoExpManTVFromContBTB,
	gasTranCoefFromContBTB      = gasTranCoefFromContBTB,
	trigVolFlowFromContBTB      = trigVolFlowFromContBTB,
	inspTimePSVFromContBTB      = inspTimePSVFromContBTB,
	SpO2FromContBTB             = SpO2FromContBTB,
	pulseRateFromContBTB        = pulseRateFromContBTB,
	perfIndexFromContBTB        = perfIndexFromContBTB,
	etCO2FromContBTB            = etCO2FromContBTB,
	respRateFromContBTB         = respRateFromContBTB,
	respRateETCO2ModFromContBTB = respRateETCO2ModFromContBTB,
	leakageFromContBTB          = leakageFromContBTB,
	hfoRateFromContBTB          = hfoRateFromContBTB,
	shareMVRespFromContBTB      = shareMVRespFromContBTB,
	FiO2FromContBTB             = FiO2FromContBTB,
	inspFlowFromContBTB         = inspFlowFromContBTB,
	expFlowFromContBTB          = expFlowFromContBTB,
    demFlowFromContBTB          = demFlowFromContBTB,
	}
return fr