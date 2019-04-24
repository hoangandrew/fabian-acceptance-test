------------------------------------------------------------------------------
-- (c) Copyright 2019 Vyaire Medical, or one of its subsidiaries.
--     All Rights Reserved.
------------------------------------------------------------------------------
-- fabian Terminal Interface library
------------------------------------------------------------------------------
pubFTI = require "FTI-Public-Define"
priFTI = require "FTI-Private-Define"
rs232  = require 'luars232'
-------------define------------
local ps      = pubFTI.patientSize
local oos     = pubFTI.onOffState
local vs      = priFTI.para_get_VentSettings
local sd      = priFTI.para_set_settingData
local cmd     = priFTI.command
local mdScale = priFTI.measuredData_ScaleFactor
local mr      = priFTI.para_measure_response
local ev      = priFTI.errorValue
local hfrc    = priFTI.hfoFreqRecCondition
local cr      = priFTI.continuousRespond
local som     = priFTI.SOM
local def     = priFTI.def
local DEBUG   = false
-------------------------------
local p, e, NBF, CMD = nil
local timeout__ms = 600
local read_len = 63 -- read one byte

-- passes in a string and makes it into a string hex
-- @str: the string we intend to make into a string hex
local function tohex(str)
if str ~= nil then 
    return (str:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end))
end
end

local function printDebug(msg)
    if (DEBUG ~= false) then print(msg) end 
end

local function roundDown(xNumber)
    local result
    if xNumber >= 0 then 
        result = math.floor(xNumber) 
    else 
        result = math.ceil(xNumber) 
    end
    return result
end

local function SplitNumberIntoHiAndLowBytes(xNumber) 
    local lowByte = xNumber % 256
    local highByte = nil
    if lowByte == xNumber then
        highByte = 0x00
    else
        highByte = roundDown(xNumber / 255)
    end
    return highByte, lowByte
end

local function getValue(xSerialData, xStartByte, xLength)
    local hexValue = tohex(xSerialData)
    local startChar = (xStartByte * 2) - 1
    local endChar = startChar + (xLength * 2) - 1
    return tonumber("0x" .. hexValue:sub(startChar, endChar))
end

local function getByteValue(xSerialData, xStartByte)
    return getValue(xSerialData, xStartByte, 1)
end

local function getUnsignedShort(xSerialData, xStartByte)
	local newUnsignedShort = getValue(xSerialData, xStartByte, 2)
	if (newUnsignedShort == ev.TERMINAL_NOTVALID) then
		newUnsignedShort = nil
	end
    return newUnsignedShort
end

local function getSignedShort(xSerialData, xStartByte)
    local unsignedShortValue = getValue(xSerialData, xStartByte, 2)
	local newSignedSV = nil
	if (unsignedShortValue ~= ev.TERMINAL_NOTVALID) then
		newSignedSV = (unsignedShortValue + (2^15)) % (2^16) - (2^15)
	end
    return (newSignedSV)
end

local function oneByteChecksum (xCheckSum)
    if xCheckSum >= 256 then
        xCheckSum = xCheckSum % 256
    end
    return xCheckSum
end

local function getScaledValue(xValue, xScale)
	local scaledValue = xValue
	if xValue ~= nil then
		scaledValue = xValue / xScale
	end
	return scaledValue
end

-- this function:
--     1. reads the data coming from the vent
--     2. splits it into which command the vent read and the data in addition
--     3. returns all data read from the vent
local function readVentData()
    local err, dataRead = p:read(read_len, timeout__ms)
	if dataRead ~=nil then printDebug('readVentData: 0x' .. tohex(dataRead)) end
    --assert(err == rs232.RS232_ERR_NOERROR)
    if dataRead ~= nil then 
        local cmdRead = getByteValue(dataRead,3)
        if getByteValue(dataRead,2) == 3 then 
            return cmdRead, getByteValue(dataRead,4) , dataRead
        elseif getByteValue(dataRead,2) == 4 then 
            return cmdRead, getUnsignedShort(dataRead,4) , dataRead
        else 
            return cmdRead, tonumber("0xFFFF") 
        end
    end 
end

local function checkForError()
    local ventData = readVentData()
	local isNotValid = (ventData == ev.TERM_PARAM_NOSUPPORT)
    if (isNotValid) then 
        assert(isNotValid, "Mode error has occured. Please select corresponding mode")
    end
	return isNotValid
end

-- this function reads in the vent data and parses it to its corresponding commands.
-- note: this applies to continuous functions (NOT WAVE)
local function readVentBreath()
    local err, dataRead = p:read(read_len, timeout__ms)
    local breathData = {}
    local cmdRead = getByteValue(dataRead,3)
    printDebug(tohex(dataRead))
    assert(err == rs232.RS232_ERR_NOERROR)
    if dataRead ~= nil then
        cmdRead = getByteValue(dataRead,3)
        breathData.mode                     = getByteValue(dataRead,      mr.ActiveVentMode)
        breathData.peakPressure             = getScaledValue(getSignedShort(dataRead,    mr.Pmax             ), mdScale.Pressure)
        breathData.meanPressure             = getScaledValue(getSignedShort(dataRead,    mr.Pmitt            ), mdScale.Pressure)
        breathData.PEEP                     = getScaledValue(getSignedShort(dataRead,    mr.PEEP             ), mdScale.Peep)
        breathData.dynamticCompliance       = getScaledValue(getUnsignedShort(dataRead,  mr.DynamicCompliance), mdScale.DynamicCompliance)
        breathData.overExtension            = getScaledValue(getUnsignedShort(dataRead,  mr.C20C             ), mdScale.OverextensionIndex)
        breathData.ventilaryResistance      = getScaledValue(getUnsignedShort(dataRead,  mr.Resistance       ), mdScale.VentilatoryResistance)
        breathData.minuteVolume             = getScaledValue(getUnsignedShort(dataRead,  mr.MV               ), mdScale.MinuteVolume)
        breathData.inspMandTidalVolume      = getScaledValue(getUnsignedShort(dataRead,  mr.TVI              ), mdScale.MandatoryTidal)
        breathData.expMandTidalVolume       = getScaledValue(getUnsignedShort(dataRead,  mr.TVE              ), mdScale.MandatoryTidal)
        breathData.expMandTVRespirator      = getScaledValue(getUnsignedShort(dataRead,  mr.TVEresp          ), mdScale.MandatoryTidal)
        breathData.expMandTVPatient         = getScaledValue(getUnsignedShort(dataRead,  mr.TVEpat           ), mdScale.MandatoryTidal)
        breathData.HFAmp                    = getScaledValue(getUnsignedShort(dataRead,  mr.HFAmpl           ), mdScale.HFOAmp)
        breathData.HFExpMandTidalVolume     = getScaledValue(getUnsignedShort(dataRead,  mr.TVEHFO           ), mdScale.MandatoryTidal)
        breathData.gasTransportCoefficient  = getUnsignedShort(dataRead,  mr.DCO2             ) 
        breathData.triggerVolumeFlow        = getScaledValue(getUnsignedShort(dataRead,  mr.TrigVol          ), mdScale.TriggerVolumeFlow)
        breathData.InspTimePSV              = getScaledValue(getUnsignedShort(dataRead,  mr.ITimePSV         ), mdScale.InspTimePSV)
        breathData.SpO2                     = getScaledValue(getSignedShort(dataRead,    mr.SPO2             ), mdScale.SPO2)
        breathData.pulseRate                = getSignedShort(dataRead,    mr.PulseRate        ) 
        breathData.perfusionIndex           = getScaledValue(getSignedShort(dataRead,    mr.PerfusionIndex   ), mdScale.PerfusionIndex)
        breathData.etCO2                    = getScaledValue(getSignedShort(dataRead,    mr.ETCO2            ), mdScale.etCO2)
        breathData.respiratoryRate          = getUnsignedShort(dataRead,  mr.BPM              ) 
        breathData.respiratoryRateETCO2Mod  = getUnsignedShort(dataRead,  mr.BPMco2           ) 
        breathData.leakage                  = getUnsignedShort(dataRead,  mr.Leak             ) 
        breathData.HFRate                   = getUnsignedShort(dataRead,  mr.HFFreq           ) 
        breathData.shareMVRespirator        = getScaledValue(getSignedShort(dataRead,    mr.Percent          ), mdScale.MinuteVolume)
        breathData.FiO2                     = getScaledValue(getUnsignedShort(dataRead,  mr.OxyVal           ), mdScale.FIO2)
        breathData.inspFlow                 = getScaledValue(getSignedShort(dataRead,    mr.INSP_FLOW        ), mdScale.Flow)
        breathData.expFlow                  = getScaledValue(getSignedShort(dataRead,    mr.EXP_FLOW         ), mdScale.Flow)
        breathData.demandFlow               = getScaledValue(getSignedShort(dataRead,    mr.DEMAND_FLOW      ), mdScale.Flow)
        return cmdRead, breathData       
    end 
end

-- this function reads in the vent data and parses it to its corresponding commands.
-- note: this applies to the continuous wave function 
local function readVentWave()
    local err, dataRead = p:read(read_len, timeout__ms)
    local wave = {}
    --assert(err == rs232.RS232_ERR_NOERROR)
    if dataRead ~= nil then 
        printDebug(tohex(dataRead))
        wd = priFTI.para_get_waveData
        wave.Pressure = getSignedShort(dataRead,wd.Pressure) / mdScale.Pressure
        wave.Flow     = getSignedShort(dataRead,wd.Flow    ) / mdScale.Flow
        wave.etCO2    = getSignedShort(dataRead,wd.etCO2   ) / mdScale.etCO2 
        return cmdRead, wave
    end
end

-- This function dictates the 'number of bytes' value by checking
-- how much data we intend to send to the vent
local function writeToSerial(xCommand, xDataByte1, xDataByte2)    
    if p ~= nil then
        local numberBytes = 0x2
        local checkSum = numberBytes + xCommand
        if xDataByte1 == nil then
            p:write(string.char(som.TERM_MSG_SOM, 
                                numberBytes, 
                                xCommand,
                                oneByteChecksum(checkSum)), 
                                timeout__ms)
            printDebug('writeToSerial: 0x' .. tohex(string.char(som.TERM_MSG_SOM, numberBytes, xCommand,oneByteChecksum(checkSum))))
        elseif xDataByte2 == nil then
            numberBytes = 0x3
            checkSum = numberBytes + xCommand + xDataByte1
            p:write(string.char(som.TERM_MSG_SOM, 
                                numberBytes, 
                                xCommand, 
                                xDataByte1,
                                oneByteChecksum(checkSum)), 
                                timeout__ms)
            printDebug('writeToSerial: 0x' .. tohex(string.char(som.TERM_MSG_SOM, numberBytes, xCommand, xDataByte1, oneByteChecksum(checkSum)))) 
        else
            numberBytes = 0x4
            checkSum = numberBytes + xCommand + xDataByte1 + xDataByte2
            p:write(string.char(som.TERM_MSG_SOM, 
                                numberBytes, 
                                xCommand, 
                                xDataByte1, 
                                xDataByte2, 
                                oneByteChecksum(checkSum)), 
                                timeout__ms)
            printDebug('writeToSerial: 0x' .. tohex(string.char(som.TERM_MSG_SOM, numberBytes, xCommand, xDataByte1, xDataByte2, oneByteChecksum(checkSum)))) 
        end 
    end
end
  
local function writingToSerial(xCommand, xDef)
	writeToSerial(xCommand)
	local cmdUsed, data = readVentData()
	local scaledData = data
	if xDef.scale ~= nil then 
	    scaledData = data / xDef.scale
	end
	if cmdUsed == xCommand and scaledData >= xDef.minimum and scaledData <= xDef.minimum then
	    return scaledData
	else 
		print("An error has occured")
	end
	if (DEBUG ~= false) then print(scaledData) end 
end

local function setValue (xCommand, xValue, xDef)
    local ScaledValue, highByte, lowByte = nil
	local isValid = (xValue >= xDef.minimum and xValue <= xDef.maximum)
	if isValid then
	    if xDef.scale ~= nil then 
		    ScaledValue = xValue * xDef.scale
			highByte, lowByte = SplitNumberIntoHiAndLowBytes(ScaledValue) 
            writeToSerial(xCommand, highByte, lowByte)
			checkForError()
		else 
		    writeToSerial(xCommand, xValue)
			checkForError()
		end
	else
	    print ("Out of range.")
	end
	checkForError()
	return isValid
end
 
local function delay_sec(xSecond)  
    local clock = os.clock
    local t0 = clock()
    while (clock() - t0) <= xSecond do end
end

local function openCOM(xPortName) 
    portError, p = rs232.open(xPortName)
    if portError == rs232.RS232_ERR_NOERROR then
        assert(p:set_baud_rate(rs232.RS232_BAUD_230400) == rs232.RS232_ERR_NOERROR)
        assert(p:set_data_bits(rs232.RS232_DATA_8) == rs232.RS232_ERR_NOERROR)
        assert(p:set_parity(rs232.RS232_PARITY_NONE) == rs232.RS232_ERR_NOERROR)
        assert(p:set_stop_bits(rs232.RS232_STOP_1) == rs232.RS232_ERR_NOERROR)
        assert(p:set_flow_control(rs232.RS232_FLOW_OFF)  == rs232.RS232_ERR_NOERROR)
        print("OK, port open with values: " .. tostring(p))
    else
        print("Can't open serial port " .. xPortName .. " error: " .. rs232.error_tostring(portError))
    end
    return portError
end

local function closeCOM()
    assert(p:close() == rs232.RS232_ERR_NOERROR)
end

local function setVentMode(xMode)
    return setValue (sd.TERMINAL_SET_VENT_MODE, xMode, def.mode)
end

local function setVetRunState(xOnOff)
    return setValue (sd.TERMINAL_SET_VENT_RUNSTATE, xOnOff, def.onOffState)
end

local function setStateVLimit(xOnOff)
    return setValue (sd.TERMINAL_SET_STATE_VLimit, xOnOff, def.onOffState)
end

local function setStateVGuarantee(xOnOff)  
    return setValue (sd.TERMINAL_SET_STATE_VGarant, xOnOff, def.onOffState)
end

local function setStateBodyWeightRange(xRange)
    return setValue (sd.TERMINAL_SET_PARAM_VentRange, xRange, def.VentRange)
end

local function setIERatioHFO(xIERatio)
    return setValue (sd.TERMINAL_SET_PARAM_IERatioHFO, xIERatio, def.IE)
end

local function setManBreathRunning(xOnOff)
    return setValue (sd.TERMINAL_SET_MANBREATHrunning, xOnOff, def.onOffState)
end

local function setStatePressureRiseControl(xMode)
    return setValue (sd.TERMINAL_SET_PressureRiseCtrl, xMode, def.RiseControl)
end 

local function setHFOFreqRec__hz(xFreq__hz)
    local isVaild = (xFreq__hz >= def.HFOFreqRec.minimum and xFreq__hz < def.HFOFreqRec.maximum or
	                 xFreq__hz == hfrc.HFOFreqRec1 or xFreq__hz == hfrc.HFOFreqRec2 or
		             xFreq__hz == hfrc.HFOFreqRec3 or xFreq__hz == hfrc.HFOFreqRec4  )
    if isVaild then
	    return setValue (sd.TERMINAL_SET_PARAM_HFOFreqRec, xFreq__hz, def.HFOFreqRec)
	end
end

local function setHFOFlow__lpm(xFreq__lpm)
    return setValue (sd.TERMINAL_SET_PARAM_HFOFlow, xFreq__lpm, def.HFOFlow)
end 

local function setLeakCompensation(xLeak)
    return setValue (sd.TERMINAL_SET_LeakCompensation, xLeak, def.LeakComp)
end 

local function setPInsPressure__mbar(xPressure__mbar)
    return setValue (sd.TERMINAL_SET_PARAM_PINSP, xPressure__mbar, def.PInspPress)
end

local function setPeep__mbar(xPeep__mbar)
    return setValue (sd.TERMINAL_SET_PARAM_PEEP, xPeep__mbar, def.PEEP)
end

local function setPSV__mbar(xPPSV__mbar)
    return setValue (sd.TERMINAL_SET_PARAM_PPSV, xPPSV__mbar, def.PPSV)
end

local function setBPM__bpm(xBreatheRate__bpm)
    local highByte, lowByte = SplitNumberIntoHiAndLowBytes(xBreatheRate__bpm)
    writeToSerial(sd.TERMINAL_SET_PARAM_BPM, dataByte, lowByte)
    checkForError()
end

local function setHFOAmp__mbar(xAmp__mbar)
    return setValue (sd.TERMINAL_SET_PARAM_HFAmpl, xAmp__mbar, def.HFOAmp)
end

local function setHFOAmpMax__mbar(xAmp__mbar)
    return setValue (sd.TERMINAL_SET_PARAM_HFAmplMax, xAmp__mbar, def.HFOAmpMAX)
end

local function setHFOFreq__hz(xFreq__hz)
    return setValue (sd.TERMINAL_SET_PARAM_HFFreq, xFreq__hz, def.HFOFreq)
end

local function setO2(xO2)
    return setValue (sd.TERMINAL_SET_PARAM_O2, xO2, def.O2)
end

local function setIFlow__lpm(xIFlow__lpm)
    return setValue (sd.TERMINAL_SET_PARAM_IFlow, xIFlow__lpm, def.Flow)
end

local function setEFlow__lpm(xEFlow__lpm)
    return setValue (sd.TERMINAL_SET_PARAM_EFlow, xEFlow__lpm, def.Flow)
end

local function setRiseTime__sec(xTime__sec)
    return setValue (sd.TERMINAL_SET_PARAM_RiseTime, xTime__sec, def.RiseTime)
end

local function setITime__sec(xTime__sec)
    return setValue (sd.TERMINAL_SET_PARAM_ITime, xTime__sec, def.ITime)
end

local function setETime__sec(xTime__sec)
    return setValue (sd.TERMINAL_SET_PARAM_ETime, xTime__sec, def.ETime)
end

local function setHFOPMean__mbar(xPMean__mbar)
    return setValue (sd.TERMINAL_SET_PARAM_HFPMean, xPMean__mbar, def.HFOPMean)
end

local function setHFOPMeanRec__mbar(xPMean__mbar)
    return setValue (sd.TERMINAL_SET_PARAM_HFPMeanRec, xPMean__mbar, def.HFOPMean)
end

local function setVLimit__ml(xVLimit__ml)
    return setValue (sd.TERMINAL_SET_PARAM_VLimit, xVLimit__ml, def.VLimit)
end

local function setVGuarantee__ml(xVGuarantee__ml)
    return setValue (sd.TERMINAL_SET_PARAM_VGarant, xVGuarantee__ml, def.VGuarantee)
end

local function setAbortCriterionPSV__per(xPSV__per)
    return setValue (sd.TERMINAL_SET_PARAM_AbortCriterionPSV, xPSV__per, def.AbortPSV) 
end

local function setTherapyFlow__lpm(xFlow__lpm)
    return setValue (sd.TERMINAL_SET_PARAM_TherapieFlow, xFlow__lpm, def.TherapyFlow) 
end

local function setTrigger(xTrigger__senHigh)
    return setValue (sd.TERMINAL_SET_PARAM_Trigger, xTrigger__senHigh, def.Trigger) 
end

local function setFlowMin__lpm(xFlow__lpm)
    return setValue (sd.TERMINAL_SET_PARAM_Flowmin, xFlow__lpm, def.FlowMin) 
end

local function setCPAP__mbar(xCPAP__mbar)
    return setValue (sd.TERMINAL_SET_PARAM_CPAP, xCPAP__mbar, def.CPAP) 
end

local function setPManuel__mbar(xPManuel__mbar)
    return setValue (sd.TERMINAL_SET_PARAM_PManual, xPManuel__mbar, def.PManuel)
end

local function setBackup(xBackup)
    return setValue (sd.TERMINAL_SET_PARAM_Backup, xBackup, def.Backup)
end

local function setITimeRec__sec(xITime__sec)
    return setValue (sd.TERMINAL_SET_PARAM_ITimeRec, xITime__sec, def.ITimeRec)
end

local function setO2Flush(xO2Flush)
    return setValue (sd.TERMINAL_SET_PARAM_O2_FLUSH, def.O2Flush)
end

local function setSPO2Low(xSPO2Low)
    return setValue (sd.TERMINAL_SET_PARAM_SPO2LOW, def.SPO2Low)
end

local function setSPO2High(xSPO2High)
    return setValue (sd.TERMINAL_SET_PARAM_SPO2HIGH, def.SPO2High)
end

local function setFIO2Low(xFIO2Low)
    return setValue (sd.TERMINAL_SET_PARAM_FIO2LOW, def.FIO2Low)
end

local function setFIO2High(xFIO2High)
    return setValue (sd.TERMINAL_SET_PARAM_FIO2HIGH, def.FIO2High)
end

local function setStatePrico(xOnOff)
    return setValue (sd.TERMINAL_SET_STATE_PRICO, xOnOff, def.onOffState)
end




--[[
setting_para = {
   { name = "Breath Rate"     , cmd = sd.TERMINAL_SET_BREATH_RATE, min = , max = , scale = },
   { name = "Inspiration Time", cmd = sd.TERMINAL_SET_BREATH_RATE, min = , max = , scale = },
}

local function setName(sd.TERMINAL_SET_STATE_PRICO, xOnOff, oos.OFF, xOnOff == oos.O)
    return setValue (sd.TERMINAL_SET_STATE_PRICO, xOnOff, oos.OFF, xOnOff == oos.ON)
end

function set(xName)
    if xName match setting_pare.name then
	    setName(sd.TERMINAL_SET_STATE_PRICO, xOnOff, oos.OFF, xOnOff == oos.O)
	do
end

function setAndVerify(xName)
    if xName match setting_pare.name then
	    setName(sd.TERMINAL_SET_STATE_PRICO, xOnOff, oos.OFF, xOnOff == oos.O)
	do
	local result = getName(xName)
	if result = false  assert("ERROR: Failed set Breath Rate at 10")
end
ft.setAndVerify("Breath Rate", 10)
--]]




--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~GET VALUES~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local function getContinuousData(xStartCmd, xStopCmd)
   local cmdUsed,ventData = nil
   if xStopCmd ~= nil then
         writeToSerial(xStartCmd)
		 cmdUsed,ventData = readVentBreath()
		 writeToSerial(xStopCmd)
   else
        writeToSerial(xStartCmd)
		cmdUsed,ventData = readVentBreath()
   end
   return cmdUsed,ventData
end

local function getContinuousWave(xStartCmd, xStopCmd)
   local cmdUsed,ventData = nil
   if xStopCmd ~= nil then
         writeToSerial(xStartCmd)
		 cmdUsed,ventData = readVentWave()
		 writeToSerial(xStopCmd)
   else
        writeToSerial(xStartCmd)
		cmdUsed,ventData = readVentWave()
   end
   return cmdUsed,ventData
end

local function getBTB()
    local cmdUsed, breathData = getContinuousData(cmd.TERM_GET_MEASUREMENTS_ONCE_BTB)
    if (cmdUsed == cr.TERM_MEASUREMENTS_BTB) then
		return breathData
    end
end

local function getContinousBTB()
    local cmdUsed, breathData = getContinuousData(cmd.TERM_GET_MEASUREMENTS_CONTINIOUS_BTB,cmd.TERM_STOP_CONTINUOUS_MEASUREMENTS)
	return breathData
end

local function getAVG()
    local cmdUsed, breathData = getContinuousData(cmd.TERM_GET_MEASUREMENTS_ONCE_AVG)
    if (cmdUsed == cr.TERM_MEASUREMENTS_AVG) then
        return breathData
    end
end

local function getContinousAVG()
    local cmdUsed, breathData = getContinuousData(cmd.TERM_GET_MEASUREMENTS_CONTINUOUS_AVG, cmd.TERM_STOP_CONTINUOUS_MEASUREMENTS)
    if (cmdUsed == cr.TERM_MEASUREMENTS_AVG) then
        return breathData
    end
end

local function getContinousWaveData()
    local cmdUsed, waveData = getContinuousWave(cmd.TERM_GET_WAVE_DATA, cmd.TERM_STOP_WAVE_DATA)
	return waveData 
end

local function getVentMode()
    return writingToSerial(cmd.TERM_GET_VENT_MODE,def.mode)
end

local function getModeOption1()
    writeToSerial(vs.TERMINAL_GET_MODE_OPTION1)
    print(readVentData() )
end

local function getModeOption2()
    writeToSerial(vs.TERMINAL_GET_MODE_OPTION2)
    print(readVentData() )
end

local function getRunState()
    return writingToSerial(vs.TERMINAL_GET_VENT_RUNSTATE, def.onOffState)
end

local function getStateVLimit()
    return writingToSerial(vs.TERMINAL_GET_STATE_VLimit,def.onOffState)
end

local function getStateVGuarentee()
    return writingToSerial(vs.TERMINAL_GET_STATE_VGarant,def.onOffState)
end

local function getVentRange()
return writingToSerial(vs.TERMINAL_GET_PARAM_VentRange,def.VentRange)
end

local function getIERatioHFO()
	return writingToSerial(vs.TERMINAL_GET_PARAM_IERatioHFO,def.IE)
end

local function getManBreathRunning()
    return writingToSerial(vs.TERMINAL_GET_MANBREATHrunning,def.onOffState)
end

local function getPressureRiseControl()
    return writingToSerial(vs.TERMINAL_GET_PressureRiseCtrl,def.RiseControl)
end

local function getHFOFreqRec()
    return writingToSerial(vs.TERMINAL_GET_PARAM_HFOFreqRec,def.HFOFreqRec)
end

local function getHFOFlow()
    return writingToSerial(vs.TERMINAL_GET_PARAM_HFOFlow,HFOFlow)
end


local function getLeakCompensation()
    return writingToSerial(vs.TERMINAL_GET_LeakCompensation,def.LeakComp)
end

local function getTriggerOption()
    return writingToSerial(vs.TERMINAL_GET_TriggerOption,def.Trigger)
end

local function getFOTOscillationState()
    return writingToSerial(vs.TERMINAL_GET_FOToscillationState,def.onOffState)
end

local function getPInsPressure()
    return writingToSerial(vs.TERMINAL_GET_PARAM_PINSP,def.PInspPress)
end

local function getPeep()
	return writingToSerial(vs.TERMINAL_GET_PARAM_PEEP,def.PEEP)
end

local function getPPSV()
	return writingToSerial(vs.TERMINAL_GET_PARAM_PPSV,def.PPSV)
end
-------------------- THIS IS NOT WORKING PROPERLY-------------------
local function getBPM()
    writeToSerial(vs.TERMINAL_GET_PARAM_BPM) 
    print(readVentData() )
end
--------------------------------------------------------------------
local function getHFOAmpl()
    return writingToSerial(vs.TERMINAL_GET_PARAM_HFAmpl,def.HFOAmp)
end

local function getHFOAmplMax()
    return writingToSerial(vs.TERMINAL_GET_PARAM_HFAmplMax,def.HFOAmpMAX)
end

local function getHFOFreq()
    return writingToSerial(vs.TERMINAL_GET_PARAM_HFFreq,def.HFOFreq) 
end

local function getO2() 
    return writingToSerial(vs.TERMINAL_GET_PARAM_O2,def.O2) 
end

local function getIFlow()
    return writingToSerial(vs.TERMINAL_GET_PARAM_IFlow,def.Flow) 
end

local function getEFlow()
    return writingToSerial(vs.TERMINAL_GET_PARAM_EFlow,def.Flow)
end

local function getRiseTime()
    return writingToSerial(vs.TERMINAL_GET_PARAM_Risetime,def.RiseTime)
end

local function getITime()
    return writingToSerial(vs.TERMINAL_GET_PARAM_ITime,def.ITime)
end

local function getETime()
    return writingToSerial(vs.TERMINAL_GET_PARAM_ETime,def.ETime)
end

local function getHFOPMean()
    return writingToSerial(vs.TERMINAL_GET_PARAM_HFPMean,def.HFOPMean)
end

local function getHFOPMeanRec()
    return writingToSerial(vs.TERMINAL_GET_PARAM_HFPMeanRec,def.HFOPMean)
end

local function getParamVLimit()
    return writingToSerial(vs.TERMINAL_GET_PARAM_VLimit,def.VLimit)
end

local function getParamVGuarantee()
    return writingToSerial(vs.TERMINAL_GET_PARAM_VGarant,def.VGuarantee)
end

local function getAbortCriterionPSV()
    return writingToSerial(vs.TERMINAL_GET_PARAM_AbortCriterionPSV,def.AbortPSV)
end

local function getTherapyFlow()
    return writingToSerial(vs.TERMINAL_GET_PARAM_TherapieFlow,def.TherapyFlow)
end

local function getTrigger()
    return writingToSerial(vs.TERMINAL_GET_PARAM_Trigger,def.Trigger)
end

local function getFlowMin()
    return writingToSerial(vs.TERMINAL_GET_PARAM_Flowmin,def.FlowMin)
end

local function getCPAP()
    return writingToSerial(vs.TERMINAL_GET_PARAM_CPAP,def.CPAP)
end

local function getPManuel()
    return writingToSerial(vs.TERMINAL_GET_PARAM_PManual,def.PManuel)
end

local function getBackup()
    return writingToSerial(vs.TERMINAL_GET_PARAM_Backup,def.Backup)
end

local function getITimeRec()
    return writingToSerial(vs.TERMINAL_GET_PARAM_ITimeRec,def.ITimeRec)
end

local function getETimeRec()
    return writingToSerial(vs.TERMINAL_GET_PARAM_ETIMERec,def.ETimeRec)
end

local function getSPO2Low()
    return writingToSerial(vs.TERMINAL_GET_PARAM_SPO2LOW,def.SPO2Low)
end

local function getSPO2High()
    return writingToSerial(vs.TERMINAL_GET_PARAM_SPO2HIGH,def.SPO2High)
end

local function getFIO2Low()
    return writingToSerial(vs.TERMINAL_GET_PARAM_FIO2LOW,def.FIO2Low)
end

function getFIO2High()
    return writingToSerial(vs.TERMINAL_GET_PARAM_FIO2HIGH,def.FIO2High)
end

local function getPRICO()
    return writingToSerial(vs.TERMINAL_GET_STATE_PRICO,def.onOffState)
end

-----------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Publish Public Interface
--------------------------------------------------------------------------------

ft = {
	openCOM						    = openCOM,
	closeCOM					    = closeCOM,
	delay_sec                       = delay_sec,
	-------------------------SET FUNCTIONS-------------------------
	setVetRunState                  = setVetRunState,
    setStateVLimit					= setStateVLimit,
    setStateVGuarantee				= setStateVGuarantee,
    setStateBodyWeightRange			= setStateBodyWeightRange,
    setIERatioHFO					= setIERatioHFO,
    setManBreathRunning				= setManBreathRunning,
    setStatePressureRiseControl		= setStatePressureRiseControl,
    setHFOFreqRec__hz				= setHFOFreqRec__hz,
    setHFOFlow__lpm					= setHFOFlow__lpm,
    setLeakCompensation				= setLeakCompensation,
    setPInsPressure__mbar			= setPInsPressure__mbar,
    setPeep__mbar					= setPeep__mbar,
    setPSV__mbar					= setPSV__mbar,
    setBPM__bpm						= setBPM__bpm,
    setHFOAmp__mbar					= setHFOAmp__mbar,
    setHFOAmpMax__mbar				= setHFOAmpMax__mbar,
    setHFOFreq__hz					= setHFOFreq__hz,
    setO2							= setO2,
    setIFlow__lpm					= setIFlow__lpm,
    setEFlow__lpm					= setEFlow__lpm,
    setRiseTime__sec				= setRiseTime__sec,
    setITime__sec					= setITime__sec,
    setETime__sec					= setETime__sec,
    setHFOPMean__mbar				= setHFOPMean__mbar,
    setHFOPMeanRec__mbar			= setHFOPMeanRec__mbar,
    setVLimit__ml					= setVLimit__ml,
    setVGuarantee__ml				= setVGuarantee__ml,
    setAbortCriterionPSV__per		= setAbortCriterionPSV__per,
    setTherapyFlow__lpm				= setTherapyFlow__lpm,
    setTrigger						= setTrigger,
    setFlowMin__lpm					= setFlowMin__lpm,
    setCPAP__mbar					= setCPAP__mbar,
    setPManuel__mbar				= setPManuel__mbar,
    setBackup						= setBackup,
    setITimeRec__sec				= setITimeRec__sec,
    setO2Flush						= setO2Flush,
    setSPO2Low						= setSPO2Low,
    setSPO2High						= setSPO2High,
    setFIO2Low						= setFIO2Low,
    setFIO2High						= setFIO2High,
    setStatePrico					= setStatePrico,
    -------------------------GET FUNCTIONS-------------------------
    getBTB   						= getBTB,
    getContinousBTB					= getContinousBTB,
    getAVG							= getAVG,
    getContinousAVG					= getContinousAVG,
    getContinousWaveData			= getContinousWaveData,
    getWaveData 					= getWaveData,
    getVentMode 					= getVentMode,
    getModeOption1					= getModeOption1,
    getModeOption2 					= getModeOption2,
    getRunState						= getRunState,
    getStateVLimit					= getStateVLimit,
    getStateVGuarentee				= getStateVGuarentee,
    getVentRange					= getVentRange,
    getIERatioHFO					= getIERatioHFO,
    getManBreathRunning				= getManBreathRunning,
    getPressureRiseControl			= getPressureRiseControl,
    getHFOFreqRec					= getHFOFreqRec,
    getHFOFlow						= getHFOFlow,
    getLeakCompensation				= getLeakCompensation,
    getTriggerOption				= getTriggerOption,
    getFOTOscillationState			= getFOTOscillationState,
    getPInsPressure					= getPInsPressure,
    getPeep							= getPeep,
    getPPSV							= getPPSV,
    getBPM							= getBPM,
    getHFOAmpl						= getHFOAmpl,
    getHFOAmplMax					= getHFOAmplMax,
    getHFOFreq						= getHFOFreq,
    getO2							= getO2,
    getIFlow						= getIFlow,
    getEFlow						= getEFlow,
    getRiseTime						= getRiseTime,
    getITime						= getITime,
    getETime						= getETime,
    getHFOPMean						= getHFOPMean,
    getHFOPMeanRec					= getHFOPMeanRec,
    getParamVLimit					= getParamVLimit,
    getParamVGuarantee				= getParamVGuarantee,
    getAbortCriterionPSV			= getAbortCriterionPSV,
    getTherapyFlow					= getTherapyFlow,
    getTrigger						= getTrigger,
    getFlowMin						= getFlowMin,
    getCPAP							= getCPAP,
    getPManuel						= getPManuel,
    getBackup						= getBackup,
    getITimeRec						= getITimeRec,
    getETimeRec						= getETimeRec,
    getSPO2Low						= getSPO2Low,
    getSPO2High						= getSPO2High,
    getFIO2High						= getFIO2High,
    getPRICO						= getPRICO,

}

return ft



