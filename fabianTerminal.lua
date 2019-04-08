------------------------------------------------------------------------------
-- (c) Copyright 2019 Vyaire Medical, or one of its subsidiaries.
--     All Rights Reserved.
------------------------------------------------------------------------------
-- fabian Terminal Interface library
------------------------------------------------------------------------------

fti = require "FTIDefine"
rs232 = require 'luars232'
local portName = "COM6"

-------------define------------
local vs      = FTI.para_get_VentSettings
local sd      = FTI.para_set_settingData
local cmd     = FTI.command
local range   = FTI.range
local mdScale = FTI.measuredData_ScaleFactor
local mr = FTI.para_measure_response

-------------------------------
local ft = {}
local p, e, NBF, CMD = nil
local timeout__ms = 600
local read_len = 63 -- read one byte

   
local function delay_sec(xSecond)  
    local clock = os.clock
    local t0 = clock()
    while (clock() - t0) <= xSecond do end
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
    return getValue(xSerialData, xStartByte, 2)
end


local function getSignedShort(xSerialData, xStartByte)
    local unsignedShortValue = getValue(xSerialData, xStartByte, 2)
    return ((unsignedShortValue + (2^15)) % (2^16) - (2^15))
end


function modeError()
    local ventData = ft.readVentData()
    if (ventData == cmd.TERM_PARAM_NOSUPPORT) then 
        print ("Mode error has occured. Please select corresponding mode")
    end
end

-- this function reads the data coming from the vent, splits it into
-- which command the vent read, and the data
-- in addition, this function returns all data read by the vent if needed
function ft.readVentData()
    local err, dataRead = p:read(read_len, timeout__ms)
    assert(e == rs232.RS232_ERR_NOERROR)
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

-- this function reads in the vent data and parses it to its corresponding commands.
-- note: this applies to continuous functions (NOT WAVE)
function ft.readVentBreath()
    local err, dataRead = p:read(read_len, timeout__ms)
    local breathData = {}
    local cmdRead = getByteValue(dataRead,3)
    print (tohex(dataRead))
    assert(e == rs232.RS232_ERR_NOERROR)
    if dataRead ~= nil then
        cmdRead = getByteValue(dataRead,3)
        breathData.mode                     = getByteValue(dataRead,      mr.ActiveVentMode)
        breathData.peakPressure             = getSignedShort(dataRead,    mr.Pmax             ) / mdScale.Pressure
        breathData.meanPressure             = getSignedShort(dataRead,    mr.Pmitt            ) / mdScale.Pressure
        breathData.PEEP                     = getSignedShort(dataRead,    mr.PEEP             ) / mdScale.Peep
        breathData.dynamticCompliance       = getUnsignedShort(dataRead,  mr.DynamicCompliance) / mdScale.DynamicCompliance
        breathData.overExtension            = getUnsignedShort(dataRead,  mr.C20C             ) / mdScale.OverextensionIndex
        breathData.ventilaryResistance      = getUnsignedShort(dataRead,  mr.Resistance       ) / mdScale.VentilatoryResistance
        breathData.minuteVolume             = getUnsignedShort(dataRead,  mr.MV               ) / mdScale.MinuteVolume
        breathData.inspMandTidalVolume      = getUnsignedShort(dataRead,  mr.TVI              ) / mdScale.MandatoryTidal
        breathData.expMandTidalVolume       = getUnsignedShort(dataRead,  mr.TVE              ) / mdScale.MandatoryTidal
        breathData.expMandTVRespirator      = getUnsignedShort(dataRead,  mr.TVEresp          ) / mdScale.MandatoryTidal
        breathData.expMandTVPatient         = getUnsignedShort(dataRead,  mr.TVEpat           ) / mdScale.MandatoryTidal
        breathData.HFAmp                    = getUnsignedShort(dataRead,  mr.HFAmpl           ) / mdScale.HFOAmp
        breathData.HFExpMandTidalVolume     = getUnsignedShort(dataRead,  mr.TVEHFO           ) / mdScale.MandatoryTidal
        breathData.gasTransportCoefficient  = getUnsignedShort(dataRead,  mr.DCO2             ) 
        breathData.triggerVolumeFlow        = getUnsignedShort(dataRead,  mr.TrigVol          ) / mdScale.TriggerVolumeFlow
        breathData.InspTimePSV              = getUnsignedShort(dataRead,  mr.ITimePSV         ) / mdScale.InspTimePSV
        breathData.SpO2                     = getSignedShort(dataRead,    mr.SPO2             ) / mdScale.SPO2
        breathData.pulseRate                = getSignedShort(dataRead,    mr.PulseRate        ) 
        breathData.perfusionIndex           = getSignedShort(dataRead,    mr.PerfusionIndex   ) / mdScale.PerfusionIndex
        breathData.etCO2                    = getSignedShort(dataRead,    mr.ETCO2            ) / mdScale.etCO2
        breathData.respiratoryRate          = getUnsignedShort(dataRead,  mr.BPM              ) 
        breathData.respiratoryRateETCO2Mod  = getUnsignedShort(dataRead,  mr.BPMco2           ) --this is not defined in the PDF
        breathData.leakage                  = getUnsignedShort(dataRead,  mr.Leak             ) 
        breathData.HFRate                   = getUnsignedShort(dataRead,  mr.HFFreq           ) 
        breathData.shareMVRespirator        = getSignedShort(dataRead,    mr.Percent          )   / mdScale.MinuteVolume
        breathData.FiO2                     = getUnsignedShort(dataRead,  mr.OxyVal           ) / mdScale.FIO2
        breathData.inspFlow                 = getSignedShort(dataRead,    mr.INSP_FLOW        )   / mdScale.Flow
        breathData.expFlow                  = getSignedShort(dataRead,    mr.EXP_FLOW         )   / mdScale.Flow
        breathData.demandFlow               = getSignedShort(dataRead,    mr.DEMAND_FLOW      )   / mdScale.Flow
        return cmdRead, breathData       
    end 
end

-- this function reads in the vent data and parses it to its corresponding commands.
-- note: this applies to the continuous wave function 
function ft.readVentWave()
    local err, dataRead = p:read(read_len, timeout__ms)
    local breathData = {}
    assert(e == rs232.RS232_ERR_NOERROR)
    if dataRead ~= nil then 
    print (tohex(dataRead))
	    wd = FTI.para_get_waveData
        breathData.wavePressure = getSignedShort(dataRead,wd.Pressure) / mdScale.Pressure
        breathData.waveFlow     = getSignedShort(dataRead,wd.Flow    ) / mdScale.Flow
        breathData.waveETCO2    = getSignedShort(dataRead,wd.etCO2   ) / mdScale.etCO2
        return cmdRead, breathData
    end
end


local function oneByteChecksum (xCheckSum)
    if xCheckSum >= 256 then
        xCheckSum = xCheckSum % 256
    end
    return xCheckSum
end



-- This function dictates the 'number of bytes' value by checking
-- how much data we intend to send to the vent
function writeToSerial(xCommand, xDataByte1, xDataByte2)    
    if p ~= nil then
        if xDataByte1 == nil then
            local numberBytes = 0x2
            local checkSum = numberBytes + xCommand
            p:write(string.char(cmd.TERM_MSG_SOM, numberBytes, xCommand,
                                oneByteChecksum(checkSum)), timeout__ms)
                                print (tohex(string.char(cmd.TERM_MSG_SOM, numberBytes, xCommand,
                                oneByteChecksum(checkSum)), timeout__ms))
        elseif xDataByte2 == nil then
            local numberBytes = 0x3
            local checkSum = numberBytes + xCommand + xDataByte1
            p:write(string.char(cmd.TERM_MSG_SOM, numberBytes, xCommand, xDataByte1,
                                oneByteChecksum(checkSum)), timeout__ms)
        else
            local numberBytes = 0x4
            local checkSum = numberBytes + xCommand + xDataByte1 + xDataByte2
            p:write(string.char(cmd.TERM_MSG_SOM, numberBytes, xCommand, xDataByte1, xDataByte2, 
                                oneByteChecksum(checkSum)), timeout__ms)
        end
    end
end


function ft.openCOM() 
    e, p = rs232.open(portName)
    if e == rs232.RS232_ERR_NOERROR then
        assert(p:set_baud_rate(rs232.RS232_BAUD_230400) == rs232.RS232_ERR_NOERROR)
        assert(p:set_data_bits(rs232.RS232_DATA_8) == rs232.RS232_ERR_NOERROR)
        assert(p:set_parity(rs232.RS232_PARITY_NONE) == rs232.RS232_ERR_NOERROR)
        assert(p:set_stop_bits(rs232.RS232_STOP_1) == rs232.RS232_ERR_NOERROR)
        assert(p:set_flow_control(rs232.RS232_FLOW_OFF)  == rs232.RS232_ERR_NOERROR)
        print("OK, port open with values " .. tostring(p))
    else
        print("Can't open serial port " .. portName .. " error: " .. rs232.error_tostring(e))
    end

    return e
end


function ft.closeCOM()
    assert(p:close() == rs232.RS232_ERR_NOERROR)
end


-- passes in a string and makes it into a string hex
-- @str: the string we intend to make into a string hex
function tohex(str)
    return (str:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end))
end

-- Will take a value that is hex and make it into a string
-- @str: the hex value we intend to make into a string
function fromhex(str)
    return (str:gsub('..', function (cc)
        return string.char(tonumber(cc, 16))
    end))
end

function ft.setVentMode(xMode)
    if (xMode >= range.modeMIN and xMode <= range.modeMAX) then
        writeToSerial(sd.TERMINAL_SET_VENT_MODE, xMode)
        modeError()
    else print ("Out of range.")
    end
end

function ft.setVetRunState(xOnOff)
    if (xOnOff == range.ON or xOnOff == range.OFF) then 
    writeToSerial(sd.TERMINAL_SET_VENT_RUNSTATE, xOnOff)
    modeError()
    else print ("Out of range.")
    end
end

function ft.setStateVLimit(xOnOff)
    if (xOnOff == range.OFF or xOnOff == range.ON) then 
    writeToSerial(sd.TERMINAL_SET_STATE_VLimit, xOnOff)
    modeError()
    else print ("Out of range.")
    end
end

function ft.setStateVGuarantee(xOnOff)  
    if (xOnOff == range.OFF or xOnOff == range.ON) then 
    writeToSerial(sd.TERMINAL_SET_STATE_VGarant, xOnOff)
    modeError()
    else print ("Out of range.")
    end
end

function ft.setStateBodyWeightRange(xRange)
    if (xRange == range.NEONATAL or xRange == range.PEDIATRIC) then 
    writeToSerial(sd.TERMINAL_SET_PARAM_VentRange, xRange)
    modeError()
    else print ("Out of range.")
    end
end

function ft.setIERatioHFO(xIERatio)
    if (xIERatio >= range.IEMIN and xIERatio <= range.IEMAX) then
        writeToSerial(sd.TERMINAL_SET_PARAM_IERatioHFO, xIERatio)
        modeError()
    else print ("Out of range.")
    end
end

function ft.setManBreathRunning(xOnOff)
    if (xOnOff == range.OFF or xOnOff == range.ON) then 
        writeToSerial(sd.TERMINAL_SET_MANBREATHrunning, xOnOff)
        modeError()
    else print ("Out of range.")
    end
end

function ft.setStatePressureRiseControl(xMode)
    if (xMode == range.RiseControlMIN or xMode == range.RiseControlMAX) then 
        writeToSerial(sd.TERMINAL_SET_PressureRiseCtrl, xMode)
        modeError()
    else print ("Out of range.")
    end
end 

function ft.setHFOFreqRec(xFreq__hz)
    if (xFreq__hz >= range.HFOFreqRecMIN and xFreq__hz <= range.HFOFreqRecMAX) then
        if (xFreq__hz >= range.HFOFreqRec1 and xFreq__hz < range.HFOFreqRec1Half) then
            xFreq__hz = range.HFOFreqRec1
        elseif (xFreq__hz >= range.HFOFreqRec1Half and xFreq__hz < range.HFOFreqRec2Half) then
            xFreq__hz = range.HFOFreqRec2
        elseif (xFreq__hz >= range.HFOFreqRec2Half and xFreq__hz < range.HFOFreqRec3Half) then
            xFreq__hz = range.HFOFreqRec3
        else
            xFreq__hz = range.HFOFreqRecMAX
        end
        local highByte, lowByte = SplitNumberIntoHiAndLowBytes(xFreq__hz)
        writeToSerial(sd.TERMINAL_SET_PARAM_HFOFreqRec, highByte, lowByte)
        modeError()
    else print ("Out of range.")
    end
end

function ft.setHFOFlow(xFreq__lpm)
    if (xFreq__lpm >= range.HFOFlowMIN and xFreq__lpm <= range.HFOFlowMAX) then
        local freqScaled = xFreq__lpm * mdScale.Flow
        local highByte, lowByte = SplitNumberIntoHiAndLowBytes(freqScaled)
        writeToSerial(sd.TERMINAL_SET_PARAM_HFOFlow, highByte, lowByte)
        modeError()
    else print ("Out of range.")
    end
end 

function ft.setLeakCompensation(xLeak)
    if (xLeak >= range.LeakCompMIN and xLeak <= range.LeakCompMAX) then 
    writeToSerial(sd.TERMINAL_SET_LeakCompensation, xLeak)
    modeError()
    else print ("Out of range.")
    end
end 

function ft.setPInsPressure(xPressure__mbar)
    if (xPressure__mbar >= range.PInspPressMIN and xPressure__mbar <= range.PInspPressMAX) then 
        local pressureScaled = xPressure__mbar * mdScale.Pressure
        local highByte, lowByte = SplitNumberIntoHiAndLowBytes(pressureScaled)
        writeToSerial(sd.TERMINAL_SET_PARAM_PINSP, highByte, lowByte)
        modeError()
    else print ("Out of range.")
    end
end

function ft.setPeep(xPeep__mbar)
    if (xPeep__mbar >= range.PEEPMIN and xPeep__mbar <= range.PEEPMAX) then 
        local peepScaled = xPeep__mbar * mdScale.Peep
        local highByte, lowByte = SplitNumberIntoHiAndLowBytes(peepScaled)
        writeToSerial(sd.TERMINAL_SET_PARAM_PEEP, highByte, lowByte)
        modeError()
    else print ("Out of range.")
    end
end

function ft.setPSV(xPPSV__mbar)
    if (xPPSV__mbar >= range.PPSVMIN and xPPSV__mbar <= range.PPSVMAX) then 
        local ppsvScaled = xPPSV__mbar * mdScale.PPSV
        local highByte, lowByte = SplitNumberIntoHiAndLowBytes(ppsvScaled)
        writeToSerial(sd.TERMINAL_SET_PARAM_PPSV, highByte, lowByte)
        modeError()
    else print ("Out of range.")
    end
end

function ft.setBPM(xBreatheRate__bpm)
    local highByte, lowByte = SplitNumberIntoHiAndLowBytes(xBreatheRate__bpm)
    writeToSerial(sd.TERMINAL_SET_PARAM_BPM, dataByte, lowByte)
    modeError()
end

function ft.setHFOAmp(xAmp__mbar)
    if (xAmp__mbar >= range.HFOAmpMIN and xAmp__mbar <= range.HFOAmpMAX) then 
        local ampScaled = xAmp__mbar * mdScale.HFOAmp
        local highByte, lowByte = SplitNumberIntoHiAndLowBytes(ampScaled)
        writeToSerial(sd.TERMINAL_SET_PARAM_HFAmpl, highByte, lowByte)
        modeError()
    else print ("Out of range.")
    end
end

function ft.setHFOAmpMax(xAmp__mbar)
    if (xAmp__mbar >= range.HFOAmpMIN and xAmp__mbar <= range.HFOAmpMAX) then 
        local ampScaled = xAmp__mbar * mdScale.HFOAmp
        local highByte, lowByte = SplitNumberIntoHiAndLowBytes(ampScaled)
        writeToSerial(sd.TERMINAL_SET_PARAM_HFAmplMax, highByte, lowByte)
        modeError()
    else print ("Out of range.")
    end
end

function ft.setHFOFreq(xFreq__hz)
    if (xFreq__hz >= range.HFOFreqMIN and xFreq__hz <= range.HFOFreqMAX) then 
        local highByte, lowByte = SplitNumberIntoHiAndLowBytes(xFreq__hz)
        writeToSerial(sd.TERMINAL_SET_PARAM_HFFreq, highByte, lowByte)
        modeError()
    else print ("Out of range.")
    end
end

function ft.setO2(xO2)
    if (xO2 >= range.O2MIN and xO2 <= range.O2MAX) then 
        writeToSerial(sd.TERMINAL_SET_PARAM_O2, xO2)   
        modeError()
    else print ("Out of range.")
    end
end

function ft.setIFlow(xIFlow__lpm)
    if (xIFlow__lpm >= range.FlowMIN and xIFlow__lpm <= range.FlowMAX) then 
        local IFlowScaled = xIFlow__lpm * mdScale.Flow
        local highByte, lowByte = SplitNumberIntoHiAndLowBytes(IFlowScaled)
        writeToSerial(sd.TERMINAL_SET_PARAM_IFlow, highByte, lowByte)
        modeError()
    else print ("Out of range.")
    end
end

function ft.setEFlow(xEFlow__lpm)
    if (xEFlow__lpm >= range.FlowMIN and xEFlow__lpm <= range.FlowMAX) then 
        local EFlowScaled = xEFlow__lpm * mdScale.Flow
        local highByte, lowByte = SplitNumberIntoHiAndLowBytes(EFlowScaled)
        writeToSerial(sd.TERMINAL_SET_PARAM_EFlow, highByte, lowByte)
        modeError()
    else print ("Out of range.")
    end
end

function ft.setRiseTime(xTime__sec)
    if (xTime__sec >= range.RiseTimeMIN and xTime__sec <= range.RiseTimeMAX) then 
        local timeScaled = xTime__sec * mdScale.Time
        local highByte, lowByte = SplitNumberIntoHiAndLowBytes(timeScaled)
        writeToSerial(sd.TERMINAL_SET_PARAM_RiseTime, highByte, lowByte)
        modeError()
    else print ("Out of range.")
    end
end

function ft.setITime(xTime__sec)
    if (xTime__sec >= range.ITimeMIN and xTime__sec <= range.ITimeMAX) then 
        local timeScaled = xTime__sec * mdScale.Time
        local highByte, lowByte = SplitNumberIntoHiAndLowBytes(timeScaled)
        writeToSerial(sd.TERMINAL_SET_PARAM_ITime, highByte, lowByte)
        modeError()
    else print ("Out of range.")
    end
end

function ft.setETime(xTime__sec)
    if (xTime__sec >= range.ETimeMIN and xTime__sec <= range.ETimeMAX) then 
        local timeScaled = xTime__sec * mdScale.Time
        local highByte, lowByte = SplitNumberIntoHiAndLowBytes(timeScaled)
        writeToSerial(sd.TERMINAL_SET_PARAM_ETime, highByte, lowByte)
        modeError()
    else print ("Out of range.")
    end
end

function ft.setHFOPMean(xPMean__mbar)
    if (xPMean__mbar >= range.HFOPMeanMIN and xPMean__mbar <= range.HFOPMeanMAX) then 
        local pmeanScaled = xPMean__mbar * mdScale.Pressure
        local highByte, lowByte = SplitNumberIntoHiAndLowBytes(pmeanScaled)
        writeToSerial(sd.TERMINAL_SET_PARAM_HFPMean, highByte, lowByte)
        modeError()
    else print ("Out of range.")
    end
end

function ft.setHFOPMeanRec(xPMean__mbar)
    if (xPMean__mbar >= range.HFOPMeanMIN and xPMean__mbar <= range.HFOPMeanMAX) then 
        local pmeanScaled = xPMean__mbar * mdScale.Pressure
        local highByte, lowByte = SplitNumberIntoHiAndLowBytes(pmeanScaled)
        writeToSerial(sd.TERMINAL_SET_PARAM_HFPMeanRec, highByte, lowByte)
        modeError()
    else print ("Out of range.")
    end 
end

function ft.setVLimit(xVLimit__ml)
    if (xVLimit__ml >= range.VLimitMIN and xVLimit__ml <= range.VLimitMAX) then 
        local vlimitScaled = xVLimit__ml * mdScale.Vol
        local highByte, lowByte = SplitNumberIntoHiAndLowBytes(vlimitScaled)
        writeToSerial(sd.TERMINAL_SET_PARAM_VLimit, highByte, lowByte)
        modeError()
    else print ("Out of range.")
    end
end

function ft.setVGuarantee(xVGuarantee__ml)
    if (xVGuarantee__ml >= range.VGuaranteeMIN and xVGuarantee__ml <= range.VGuaranteeMAX) then 
        local vguaranteeScaled = xVGuarantee__ml * mdScale.Vol
        local highByte, lowByte = SplitNumberIntoHiAndLowBytes(vguaranteeScaled)
        writeToSerial(sd.TERMINAL_SET_PARAM_VGarant, highByte, lowByte)
        modeError()
    else print ("Out of range.")
    end
end

function ft.setAbortCriterionPSV(xPSV__per)
    if (xPSV__per >= range.AbortPSVMIN and xPSV__per <= range.AbortPSVMAX) then 
        writeToSerial(sd.TERMINAL_SET_PARAM_AbortCriterionPSV, xPSV__per)
        modeError()
    else print ("Out of range.")
    end
end

function ft.setTherapyFlow(xFlow__lpm)
    if (xFlow__lpm >= range.TherapyFlowMIN and xFlow__lpm <= range.TherapyFlowMAX) then 
        local flowScaled = xFlow__lpm * mdScale.Flow
        local highByte, lowByte = SplitNumberIntoHiAndLowBytes(flowScaled)
        writeToSerial(sd.TERMINAL_SET_PARAM_TherapieFlow, highByte, lowByte)
        modeError()
    else print ("Out of range.")
    end
end


function ft.setTrigger(xTrigger__senHigh)
    if (xTrigger__senHigh >= range.TriggerMIN and xTrigger__senHigh <= range.TriggerMAX) then 
        local triggerScaled = xTrigger__senHigh * mdScale.Trigger
        local highByte, lowByte = SplitNumberIntoHiAndLowBytes(triggerScaled)
        writeToSerial(sd.TERMINAL_SET_PARAM_Trigger, highByte, lowByte)
        modeError()
    else print ("Out of range.")
    end
end


function ft.setFlowMin(xFlow__lpm)
    if (xFlow__lpm >= range.FlowMinuteMIN and xFlow__lpm <= range.FlowMinuteMAX) then 
        local flowScaled = xFlow__lpm * mdScale.Flow
        local highByte, lowByte = SplitNumberIntoHiAndLowBytes(flowScaled)
        writeToSerial(sd.TERMINAL_SET_PARAM_Flowmin, highByte, lowByte)
        modeError()
    else print ("Out of range.")
    end
end

function ft.setCPAP(xCPAP__mbar) 
    if (xCPAP__mbar >= range.CPAPMIN and xCPAP__mbar <= range.CPAPMAX) then 
        local cpapScaled = xCPAP__mbar * mdScale.CPAP
        local highByte, lowByte = SplitNumberIntoHiAndLowBytes(cpapScaled)
        writeToSerial(sd.TERMINAL_SET_PARAM_CPAP, highByte, lowByte)
        modeError()
    else print ("Out of range.")
    end
end

function ft.setPManuel(xPManuel__mbar)
    if (xPManuel__mbar >= range.PManuelMIN and xPManuel__mbar <= range.PManuelMAX) then 
        local pmanuelScaled = xPManuel__mbar * mdScale.PManuel
        local highByte, lowByte = SplitNumberIntoHiAndLowBytes(pmanuelScaled)
        writeToSerial(sd.TERMINAL_SET_PARAM_PManual, highByte, lowByte)
        modeError()
    else print ("Out of range.")
    end
end

function ft.setBackup(xBackup)
    if (xBackup >= range.BackupMIN and xBackup <= range.BackupMAX) then 
        writeToSerial(sd.TERMINAL_SET_PARAM_Backup, xBackup)
        modeError()
    else print ("Out of range.")
    end
end

function ft.setITimeRec(xITime__sec)
    if (xITime__sec >= range.ITimeRecMIN and xITime__sec <= range.ITimeRecMAX) then 
        local itimeScaled = xITime__sec * mdScale.Time
        local highByte, lowByte = SplitNumberIntoHiAndLowBytes(itimeScaled)
        writeToSerial(sd.TERMINAL_SET_PARAM_ITimeRec, highByte, lowByte)
        modeError()
    else print ("Out of range.")
    end
end

function ft.setO2Flush(xO2Flush)
    if (xO2Flush >= range.O2FlushMIN and xO2Flush <= range.O2FlushMAX) then 
        writeToSerial(sd.TERMINAL_SET_PARAM_O2_FLUSH, xO2Flush)
        modeError()
    else print ("Out of range.")
    end
end

function ft.setSPO2Low(xSPO2Low)
    if (xSPO2Low >= range.SPO2LowMIN and xSPO2Low <= range.SPO2LowMAX) then 
        writeToSerial(sd.TERMINAL_SET_PARAM_SPO2LOW, xSPO2Low)
        modeError()
    else print ("Out of range.")
    end
end

function ft.setSPO2High(xSPO2High)
    if (xSPO2High >= range.SPO2HighMIN and xSPO2High <= range.SPO2HighMAX) then 
        writeToSerial(sd.TERMINAL_SET_PARAM_SPO2HIGH, xSPO2High)
        modeError()
    else print ("Out of range.")
    end
end

function ft.setFIO2Low(xFIO2Low)
    if (xFIO2Low >= range.FIO2LowMIN and xFIO2Low <= range.FIO2LowMAX) then 
        writeToSerial(sd.TERMINAL_SET_PARAM_FIO2LOW, xFIO2Low)
        modeError()
    else print ("Out of range.")
    end
end

function ft.setFIO2High(xFIO2High)
    if (xSPO2High >= range.FIO2HighMIN and xSPO2High <= range.FIO2HighMAX) then 
        writeToSerial(sd.TERMINAL_SET_PARAM_FIO2HIGH, xFIO2High)
        modeError()
    else print ("Out of range.")
    end
end

function ft.setStatePrico(xOnOff)
    if (xOnOff == range.OFF or xOnOff == range.ON) then 
        writeToSerial(sd.TERMINAL_SET_STATE_PRICO, xOnOff)
        modeError()
    else print ("Out of range.")
    end
end


--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~GET VALUES~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


function ft.getBTB()
    writeToSerial(cmd.TERM_GET_MEASUREMENTS_ONCE_BTB)
    local cmdUsed, breathData = ft.readVentBreath()
    if (cmdUsed == cmd.TERM_GET_MEASUREMENTS_ONCE_BTB) then
        --does not print in order
        for k, v in pairs(breathData) do
            if (v == range.MissingValueLOW or 
                v == range.MissingValueMID or 
                v == range.MissingValueHIGH )then
              else  
                print(k .. " = " ..  v)
            end 
        end
    end
end

function ft.getContinousBTB(xIterations)
    writeToSerial(cmd.TERM_STOP_CONTINUOUS_MEASUREMENTS)
    writeToSerial(cmd.TERM_GET_MEASUREMENTS_CONTINIOUS_BTB)
    local cmdRead, breathData = nil
    for  i = 1,   xIterations do
        print ("---------------------------------------")
        -- ft.delay_sec(1.4) --we need this delay here for the vent to send all the data
		delay_sec(1.4)
        cmdRead, breathData = ft.readVentBreath()
        if (cmdRead == 0) then
            for k, v in pairs(breathData) do
                if (v == range.MissingValueLOW or 
                    v == range.MissingValueMID or 
                    v == range.MissingValueHIGH )then
                else  
                    print(k .. " = " ..  v)
                end 
            end
        end
    end
    writeToSerial(cmd.TERM_STOP_CONTINUOUS_MEASUREMENTS)
end
-------------------------------------------------------


function ft.getAVG()
    writeToSerial(cmd.TERM_GET_MEASUREMENTS_ONCE_AVG)
    local cmdUsed, breathData = ft.readVentBreath()
    if (cmdUsed == 2) then
        --does not print in order
        for k, v in pairs(breathData) do
            if (v == range.MissingValueLOW or 
                v == range.MissingValueMID or 
                v == range.MissingValueHIGH )then
              else  
                print(k .. " = " ..  v)
            end 
        end
    end
end

function ft.getContinousAVG(xIterations)
    writeToSerial(cmd.TERM_STOP_CONTINUOUS_MEASUREMENTS)
    writeToSerial(cmd.TERM_GET_MEASUREMENTS_CONTINUOUS_AVG)
    local cmdRead, breathData = nil
    for  i = 1,   xIterations do
        print ("---------------------------------------")
        ft.delay_sec(1.4) --we need this delay here for the vent to send all the data
        cmdRead, breathData = ft.readVentBreath()
        if (cmdRead == 2) then
        --does not print in order

            for k, v in pairs(breathData) do
                if (v == range.MissingValueLOW or 
                    v == range.MissingValueMID or 
                    v == range.MissingValueHIGH )then
                else  
                    print(k .. " = " ..  v)
                end 
            end
        end
    end
    writeToSerial(cmd.TERM_STOP_CONTINUOUS_MEASUREMENTS)
end
-------------------------------------------------------
function ft.getContinousWaveData(xIterations)
    writeToSerial(cmd.TERM_STOP_WAVE_DATA)
    writeToSerial(cmd.TERM_GET_WAVEDATA)
    local cmdRead, breathData = nil
    for  i = 1,   xIterations do
        print ("---------------------------------------")
        ft.delay_sec(.4) --we need this delay here for the vent to send all the data
        cmdRead, breathData = ft.readVentWave()
        if breathData ~= nil then
            for k, v in pairs(breathData) do
                if (v == range.MissingValueLOW or 
                    v == range.MissingValueMID or 
                    v == range.MissingValueHIGH )then
                else  
                    print(k .. " = " ..  v)
                end 
            end
        end
    end
    writeToSerial(cmd.TERM_STOP_WAVE_DATA)
end
-------------------------------------------------------

function ft.getVentMode()
    writeToSerial(vs.TERMINAL_GET_VENT_MODE)
    local cmdUsed, data = ft.readVentData()
    if (cmdUsed == tonumber(vs.TERMINAL_GET_VENT_MODE)) then
        if (data >= range.modeMIN or data <= range.modeMAX) then
            return data
        else print("An error has occured")
        end 
    end
end

function ft.getModeOption1()
    writeToSerial(vs.TERMINAL_GET_MODE_OPTION1)
    print(ft.readVentData() )
end

function ft.getModeOption2()
    writeToSerial(vs.TERMINAL_GET_MODE_OPTION2)
    print(ft.readVentData() )
end

function ft.getRunState()
    writeToSerial(vs.TERMINAL_GET_VENT_RUNSTATE)
    local cmdUsed, data = ft.readVentData()
    
    if (cmdUsed == tonumber(vs.TERMINAL_GET_VENT_RUNSTATE)) then
        if (data == range.ON or data == range.OFF) then
            return data
        else print("An error has occured")
        end 
    end
end

function ft.getStateVLimit()
    writeToSerial(vs.TERMINAL_GET_STATE_VLimit)
    local cmdUsed, data = ft.readVentData()
    if (cmdUsed == tonumber(vs.TERMINAL_GET_STATE_VLimit)) then
        if (data == range.ON or data == range.OFF) then
            return data
        else print("An error has occured")
        end 
    else print("Volume Limit is not selected")
    end
end

function ft.getStateVGuarentee()
    writeToSerial(vs.TERMINAL_GET_STATE_VGarant)   
    local cmdUsed, data = ft.readVentData()
    if (cmdUsed == tonumber(vs.TERMINAL_GET_STATE_VGarant)) then
        if (data == range.ON or data == range.OFF) then
            return data
        else print("An error has occured")
        end 
    else print("Volume Limit is not selected")
    end
end

function ft.getVentRange()
    writeToSerial(vs.TERMINAL_GET_PARAM_VentRange) 
    local cmdUsed, data,hex = ft.readVentData()
    if (cmdUsed == tonumber(vs.TERMINAL_GET_PARAM_VentRange)) then
        if (data == range.NEONATAL or data == range.PEDIATRIC) then
            return data
        else print("An error has occured")
        end
    end
end

function ft.getIERatioHFO()
    writeToSerial(vs.TERMINAL_GET_PARAM_IERatioHFO)    
    local cmdUsed, data = ft.readVentData()
    if (cmdUsed == tonumber(vs.TERMINAL_GET_PARAM_IERatioHFO)) then
        if (data >= range.IEMIN and data <= range.IEMAX) then
            return data
        else print("An error has occured")
        end
    end
end

function ft.getManBreathRunning()
    writeToSerial(vs.TERMINAL_GET_MANBREATHrunning)    
    local cmdUsed, data = ft.readVentData()
    if (cmdUsed == tonumber(vs.TERMINAL_GET_MANBREATHrunning)) then
        if (data == range.ON or data == range.OFF) then
            return data
        else print("An error has occured")
        end
    end
end

function ft.getPressureRiseControl()
    writeToSerial(vs.TERMINAL_GET_PressureRiseCtrl)
    local cmdUsed, data = ft.readVentData()
    if (cmdUsed == tonumber(vs.TERMINAL_GET_PressureRiseCtrl)) then
            if (data == range.RiseControlMIN or data == range.RiseControlMAX) then
            return data
        else print("An error has occured")
        end
    end
end

function ft.getHFOFreqRec()
    writeToSerial(vs.TERMINAL_GET_PARAM_HFOFreqRec)
    local cmdUsed, data = ft.readVentData()
    if (cmdUsed == tonumber(vs.TERMINAL_GET_PARAM_HFOFreqRec)) then
        if (data >= range.HFOFreqRecMIN and data <= range.HFOFreqRecMAX) then
            return data 
        else print("An error has occured")
        end
    else print("HFO mode not selected")
    end
    
end

function ft.getHFOFlow()
    writeToSerial(vs.TERMINAL_GET_PARAM_HFOFlow)
    local cmdUsed, data, allData = ft.readVentData()
    local scaledData = data / mdScale.Flow
    if (cmdUsed == tonumber(vs.TERMINAL_GET_PARAM_HFOFlow)) then
        if (scaledData >= range.HFOFlowMIN and scaledData <= range.HFOFlowMAX) then
            return scaledData   
        else print("An error has occured")
        end
    else print("HFO mode not selected")
    end
end


function ft.getLeakCompensation()
    writeToSerial(vs.TERMINAL_GET_LeakCompensation)    
    local cmdUsed, data = ft.readVentData()
    if (cmdUsed == tonumber(vs.TERMINAL_GET_LeakCompensation)) then
        if (data >= range.LeakCompMIN and data <= range.LeakCompMAX) then
            return data 
        else print("An error has occured")
        end
    end
end

function ft.getTriggerOption()
    writeToSerial(vs.TERMINAL_GET_TriggerOption)   
    local cmdUsed, data = ft.readVentData()
    if (cmdUsed == tonumber(vs.TERMINAL_GET_TriggerOption)) then
        if (data >= range.TriggerMIN and data <= range.TriggerMAX) then
            return data 
        else print("An error has occured")
        end
    end
end

function ft.getFOTOscillationState()
    writeToSerial(vs.TERMINAL_GET_FOToscillationState)
    local cmdUsed, data = ft.readVentData()
    if (cmdUsed == tonumber(vs.TERMINAL_GET_FOToscillationState)) then
        if (data == range.ON or data == range.OFF) then
            return data
        else print("An error has occured")
        end 
    end
end

function ft.getPInsPressure()
    writeToSerial(vs.TERMINAL_GET_PARAM_PINSP)
    local cmdUsed, data = ft.readVentData()
    local scaledData = data / mdScale.Pressure
    if (cmdUsed == tonumber(vs.TERMINAL_GET_PARAM_PINSP)) then
        if (scaledData >= range.PInspPressMIN and scaledData <= range.PInspPressMAX) then
            return scaledData   
        else print("An error has occured")
        end
    end
end

function ft.getPeep()
    writeToSerial(vs.TERMINAL_GET_PARAM_PEEP)
    local cmdUsed, data = ft.readVentData()
    local scaledData = data / mdScale.Peep
    if (cmdUsed == tonumber(vs.TERMINAL_GET_PARAM_PEEP)) then
        if (scaledData >= range.PEEPMIN and scaledData <= range.PEEPMAX) then
            return scaledData   
        else print("An error has occured")
        end
    end
end

function ft.getPPSV()
    writeToSerial(vs.TERMINAL_GET_PARAM_PPSV)
    local cmdUsed, data = ft.readVentData()
    local scaledData = data / mdScale.PPSV
    if (cmdUsed == tonumber(vs.TERMINAL_GET_PARAM_PPSV)) then
        if (scaledData >= range.PPSVMIN and scaledData <= range.PPSVMAX) then
            return scaledData   
        else print("An error has occured")
        end
    end
end

-------------------- THIS IS NOT WORKING PROPERLY-------------------
function ft.getBPM()
    writeToSerial(vs.TERMINAL_GET_PARAM_BPM) 
    print(ft.readVentData() )
end
--------------------------------------------------------------------
function ft.getHFOAmpl()
    writeToSerial(vs.TERMINAL_GET_PARAM_HFAmpl)
    local cmdUsed, data = ft.readVentData()
    local scaledData = data / mdScale.HFOAmp
    if (cmdUsed == tonumber(vs.TERMINAL_GET_PARAM_HFAmpl)) then
        if (scaledData >= range.HFOAmpMIN and scaledData <= range.HFOAmpMAX) then
            return scaledData   
        else print("An error has occured")
        end
    end
end

function ft.getHFOAmplMax()
    writeToSerial(vs.TERMINAL_GET_PARAM_HFAmplMax)
    local cmdUsed, data = ft.readVentData()
    local scaledData = data / mdScale.HFOAmp
    if (cmdUsed == tonumber(vs.TERMINAL_GET_PARAM_HFAmplMax)) then
        if (scaledData >= range.HFOAmpMIN and scaledData <= range.HFOAmpMAX) then
            return scaledData   
        else print("An error has occured")
        end
    end 
end

function ft.getHFOFreq()
    writeToSerial(vs.TERMINAL_GET_PARAM_HFFreq)
    local cmdUsed, data = ft.readVentData()
    if (cmdUsed == tonumber(vs.TERMINAL_GET_PARAM_HFFreq)) then
        if (data >= range.HFOFreqMIN and data <= range.HFOFreqMAX) then
            return data 
        else print("An error has occured")
        end
    end 
end

function ft.getO2() 
    writeToSerial(vs.TERMINAL_GET_PARAM_O2)
    local cmdUsed, data = ft.readVentData()
    if (cmdUsed == tonumber(vs.TERMINAL_GET_PARAM_O2)) then
        if (data >= range.O2MIN and data <= range.O2MAX) then
            return data 
        else print("An error has occured")
        end
    end 
end

function ft.getIFlow()
    writeToSerial(vs.TERMINAL_GET_PARAM_IFlow)
    local cmdUsed, data = ft.readVentData()
    local scaledData = data / mdScale.Flow
    if (cmdUsed == tonumber(vs.TERMINAL_GET_PARAM_IFlow)) then
        if (scaledData >= range.FlowMIN and scaledData <= range.FlowMAX) then
            return scaledData   
        else print("An error has occured")
        end
    end 
end

function ft.getEFlow()
    writeToSerial(vs.TERMINAL_GET_PARAM_EFlow)
    local cmdUsed, data = ft.readVentData()
    local scaledData = data / mdScale.Flow
    if (cmdUsed == tonumber(vs.TERMINAL_GET_PARAM_EFlow)) then
        if (scaledData >= range.FlowMIN and scaledData <= range.FlowMAX) then
            return scaledData   
        else print("An error has occured")
        end
    end 
end

function ft.getRiseTime()
    writeToSerial(vs.TERMINAL_GET_PARAM_Risetime)
    local cmdUsed, data = ft.readVentData()
    local scaledData = data / mdScale.Time
    if (cmdUsed == tonumber(vs.TERMINAL_GET_PARAM_Risetime)) then
        if (scaledData >= range.RiseTimeMIN and scaledData <= range.RiseTimeMAX) then
            return scaledData   
        else print("An error has occured")
        end
    end 
end

function ft.getITime()
    writeToSerial(vs.TERMINAL_GET_PARAM_ITime)
    local cmdUsed, data = ft.readVentData()
    local scaledData = data / mdScale.Time
    if (cmdUsed == tonumber(vs.TERMINAL_GET_PARAM_ITime)) then
        if (scaledData >= range.ITimeMIN and scaledData <= range.ITimeMAX) then
            return scaledData   
        else print("An error has occured")
        end
    end 
end

function ft.getETime()
    writeToSerial(vs.TERMINAL_GET_PARAM_ETime)
    local cmdUsed, data = ft.readVentData()
    local scaledData = data / mdScale.Time
    if (cmdUsed == tonumber(vs.TERMINAL_GET_PARAM_ETime)) then
        if (scaledData >= range.ETimeMIN and scaledData <= range.ETimeMAX) then
            return scaledData   
        else print("An error has occured")
        end
    end 
end

function ft.getHFOPMean()
    writeToSerial(vs.TERMINAL_GET_PARAM_HFPMean)
    local cmdUsed, data = ft.readVentData()
    local scaledData = data / mdScale.Pressure
    if (cmdUsed == tonumber(vs.TERMINAL_GET_PARAM_HFPMean)) then
        if (scaledData >= range.HFOPMeanMIN and scaledData <= range.HFOPMeanMAX) then
            return scaledData   
        else print("An error has occured")
        end
    end 
end

function ft.getHFOPMeanRec()
    writeToSerial(vs.TERMINAL_GET_PARAM_HFPMeanRec)
    local cmdUsed, data = ft.readVentData()
    local scaledData = data / mdScale.Pressure
    if (cmdUsed == tonumber(vs.TERMINAL_GET_PARAM_HFPMeanRec)) then
        if (scaledData >= range.HFOPMeanMIN and scaledData <= range.HFOPMeanMAX) then
            return scaledData   
        else print("An error has occured")
        end
    end 
end

function ft.getParamVLimit()
    writeToSerial(vs.TERMINAL_GET_PARAM_VLimit)
    local cmdUsed, data = ft.readVentData()
    local scaledData = data / mdScale.Vol
    if (cmdUsed == tonumber(vs.TERMINAL_GET_PARAM_VLimit)) then
        if (scaledData >= range.VLimitMIN and scaledData <= range.VLimitMAX) then
            return scaledData   
        else print("An error has occured")
        end
    end 
end

function ft.getParamVGuarantee()
    writeToSerial(vs.TERMINAL_GET_PARAM_VGarant)
    local cmdUsed, data = ft.readVentData()
    local scaledData = data / mdScale.Vol
    if (cmdUsed == tonumber(vs.TERMINAL_GET_PARAM_VGarant)) then
        if (scaledData >= range.VGuaranteeMIN and scaledData <= range.VGuaranteeMAX) then
            return scaledData   
        else print("An error has occured")
        end
    end 
end

function ft.getAbortCriterionPSV()
    writeToSerial(vs.TERMINAL_GET_PARAM_AbortCriterionPSV)
    local cmdUsed, data = ft.readVentData()
    if (cmdUsed == tonumber(vs.TERMINAL_GET_PARAM_AbortCriterionPSV)) then
        if (data >= range.AbortPSVMIN and data <= range.AbortPSVMAX) then
            return data 
        else print("An error has occured")
        end
    end 
end

function ft.getTherapyFlow()
    writeToSerial(vs.TERMINAL_GET_PARAM_TherapieFlow)
    local cmdUsed, data = ft.readVentData()
    local scaledData = data / mdScale.Flow
    if (cmdUsed == tonumber(vs.TERMINAL_GET_PARAM_TherapieFlow)) then
        if (scaledData >= range.TherapyFlowMIN and scaledData <= range.TherapyFlowMAX) then
            return scaledData   
        else print("An error has occured")
        end
    end 
end

function ft.getTrigger()
    writeToSerial(vs.TERMINAL_GET_PARAM_Trigger)
    local cmdUsed, data = ft.readVentData()
    local scaledData = data / mdScale.TriggerVolumeFlow
    if (cmdUsed == tonumber(vs.TERMINAL_GET_PARAM_Trigger)) then
        if (scaledData >= range.TriggerMIN and scaledData <= range.TriggerMAX) then
            return scaledData   
        else print("An error has occured")
        end
    end 
end

function ft.getFlowMin()
    writeToSerial(vs.TERMINAL_GET_PARAM_Flowmin)
    local cmdUsed, data = ft.readVentData()
    local scaledData = data / mdScale.Flow
    if (cmdUsed == tonumber(vs.TERMINAL_GET_PARAM_Flowmin)) then
        if (scaledData >= range.FlowMinuteMIN and scaledData <= range.FlowMinuteMAX) then
            return scaledData   
        else print("An error has occured")
        end
    end 
end

function ft.getCPAP()
    writeToSerial(vs.TERMINAL_GET_PARAM_CPAP)
    local cmdUsed, data = ft.readVentData()
    local scaledData = data / mdScale.CPAP
    if (cmdUsed == tonumber(vs.TERMINAL_GET_PARAM_CPAP)) then
        if (scaledData >= range.CPAPMIN and scaledData <= range.CPAPMAX) then
            return scaledData   
        else print("An error has occured")
        end
    else print("CPAP / NCPAP mode not selected")
    end 
end

function ft.getPManuel()
    writeToSerial(vs.TERMINAL_GET_PARAM_PManual)
    local cmdUsed, data = ft.readVentData()
    local scaledData = data / mdScale.PManuel
    if (cmdUsed == tonumber(vs.TERMINAL_GET_PARAM_PManual)) then
        if (scaledData >= range.PManuelMIN and scaledData <= range.PManuelMAX) then
            return scaledData   
        else print("An error has occured")
        end
    end 
end

function ft.getBackup()
    writeToSerial(vs.TERMINAL_GET_PARAM_Backup)
    local cmdUsed, data = ft.readVentData()
    if (cmdUsed == tonumber(vs.TERMINAL_GET_PARAM_Backup)) then
        if (data >= range.BackupMIN and data <= range.BackupMAX) then
            return data 
        else print("An error has occured")
        end
    end 
end

function ft.getITimeRec()
    writeToSerial(vs.TERMINAL_GET_PARAM_ITimeRec)
    local cmdUsed, data = ft.readVentData()
    local scaledData = data / mdScale.Time
    if (cmdUsed == tonumber(vs.TERMINAL_GET_PARAM_ITimeRec)) then
        if (scaledData >= range.ITimeRecMIN and scaledData <= range.ITimeRecMAX) then
            return scaledData   
        else print("An error has occured")
        end
    else print("HFO mode not selected")
    end 
end

function ft.getETimeRec()
    writeToSerial(vs.TERMINAL_GET_PARAM_ETIMERec)
    local cmdUsed, data = ft.readVentData()
    local scaledData = data / mdScale.Time
    if (cmdUsed == tonumber(vs.TERMINAL_GET_PARAM_ETIMERec)) then
        if (scaledData >= range.ETimeRecMIN and scaledData <= range.ETimeRecMAX) then 
            return scaledData   
        else print("An error has occured")
        end
    end 
end

function ft.getSPO2Low()
    writeToSerial(vs.TERMINAL_GET_PARAM_SPO2LOW)
    local cmdUsed, data = ft.readVentData()
    if (cmdUsed == tonumber(vs.TERMINAL_GET_PARAM_SPO2LOW)) then
        if (data >= range.SPO2LowMIN and data <= range.SPO2LowMAX) then
            return data 
        else print("An error has occured")
        end
    end 
end

function ft.getSPO2High()
    writeToSerial(vs.TERMINAL_GET_PARAM_SPO2HIGH)
    local cmdUsed, data = ft.readVentData()
    if (cmdUsed == tonumber(vs.TERMINAL_GET_PARAM_SPO2HIGH)) then
        if (data >= range.SPO2HighMIN and data <= range.SPO2HighMAX) then
            return data 
        else print("An error has occured")
        end
    end 
end

function ft.getFIO2Low()
    writeToSerial(vs.TERMINAL_GET_PARAM_FIO2LOW)
    local cmdUsed, data = ft.readVentData()
    local scaledData = data / mdScale.FIO2
    if (cmdUsed == tonumber(vs.TERMINAL_GET_PARAM_FIO2LOW)) then
        if (scaledData >= range.FIO2LowMIN and scaledData <= range.FIO2LowMAX) then
            return scaledData   
        else print("An error has occured")
        end
    end 
end

function ft.getFIO2High()
    writeToSerial(vs.TERMINAL_GET_PARAM_FIO2HIGH)
    local cmdUsed, data = ft.readVentData()
    if (cmdUsed == tonumber(vs.TERMINAL_GET_PARAM_FIO2HIGH)) then
        if (data >= range.FIO2HighMIN and data <= range.FIO2HighMAX) then
            return data 
        else print("An error has occured")
        end
    end 
end

function ft.getPRICO()
    writeToSerial(vs.TERMINAL_GET_STATE_PRICO)
    local cmdUsed, data = ft.readVentData()
    if (cmdUsed == tonumber(vs.TERMINAL_GET_STATE_PRICO)) then
        if (data == range.ON or data == range.OFF) then
            return data
        else print("An error has occured")
        end 
    end 
end







return ft

