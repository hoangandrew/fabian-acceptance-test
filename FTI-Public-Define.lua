------------------------------------------------------------------------------
-- (c) Copyright 2019 Vyaire Medial, or one of its subsidiaries.
--     All Rights Reserved.
------------------------------------------------------------------------------
-- Public Define fabian Terminal Interface
------------------------------------------------------------------------------

--public
local ventMode = {
    NONE      =  0,
    IPPV      =  1,
    SIPPV     =  2,
    SIMV      =  3,
    SIMVPSV   =  4,
    PSV       =  5,
    CPAP      =  6,
    NCPAP     =  7,
    DUOPAP    =  8,
    HFO       =  9,
    O2Therapy = 10,
    SERVICE   = 15
}

--public
local riseControl = {
     iFlow = 0,
     pressure = 1 
}


--public
local ModeOption1 = {
    StartStopBit                         = 0,  -- 0=Start, 1=Stop
    StateVolumnGuaranteeBit              = 1,  -- 0=off, 1=on
    StateVolumnLimitBit                  = 2,  -- 0=off, 1=on
    VentilatorRangeBit                   = 3,  -- 0=NEONATAL, 1=PEDIATRIC
    FlowSensorCalibrationRunningBit      = 4,
    O2CompensationEnabledBit             = 5,
    ExhalationValveCalibrationRunningBit = 6,
    TriggerModeBit                       = 7,  -- 0=Volumetrigger, 1=Flowtrigger
    CalibrationProcess_21_O2_RunningBit  = 8,
    CalibrationProcess_100_O2_RunningBit = 9,
    TubeSet_InfantFlow_MediJetBit        = 10,  -- NCPAP/DUOPAP
                                                -- xxxx 00xx xxxx xxxx = InfantFlow
                                                -- xxxx 01xx xxxx xxxx = MediJet
    TubeSet_InfantFlowLPBit              = 11,  -- xxxx 10xx xxxx xxxx = InfantFlowLP
                                                -- xxxx 11xx xxxx xxxx = others notdef
    IERatioHFOBit11                      = 12,  -- Bit 12+13: I:E Ratio HFO:
                                                -- xx00 xxxx xxxx xxxx = 1:3
                                                -- xx01 xxxx xxxx xxxx = 1:2
    IERatioHFOBit12                      = 13,  -- xx10 xxxx xxxx xxxx = 1:1
                                                -- xx11 xxxx xxxx xxxx = others notdef
    InternalUseBit                       = 14,
    ManualBreathRunningBit               = 15
}

--public
local ModeOption2 = {
    PressureRiseControlBit0  = 0,          -- xxxx xx00 = I-Flow
    PressureRiseControlBit1  = 1,          -- xxxx xx01 = 01=Ramp
                                           -- xxxx xx10 = AutoIFlow
                                           -- xxxx xx11 = others notdef
    HFORecruitmentBit        = 2,          -- 0=off, 1==on
    HFOFlowBit               = 3,          -- 0=off, 1==on
    ReservedBit              = 4,          -- not used
    BiasFlowBit              = 5,          -- 0==internal, 1 == external
    TriggerModeBit6          = 6,          -- xxx0 00xx xxxx = volume trigger
    TriggerModeBit7          = 7,          -- xxx0 01xx xxxx = flow trigger
    TriggerModeBit8          = 8,          -- xxx0 10xx xxxx = pressure trigger
                                           -- xxx0 xxxx xxxx = for future setting
    FOTOscillationRunningBit = 9,         
    LeakCompensationBit10    = 10,         -- 00xx xxxx xxxx = off
    LeakCompensationBit11    = 11,         -- 01xx xxxx xxxx = low
                                            -- 10xx xxxx xxxx = middle
                                            -- 11xx xxxx xxxx = high
}


local patientSize = {
    NEONATAL               =     1,
    PEDIATRIC              =     2,
}

local onOffState = {
    OFF                    =     0,
    ON                     =     1,
}

local pressureTolerance__cmH2O = {absolute = 1  , percent = 3  }
local flowTolerance__lpm       = {absolute = 0.5, percent = 10 }
local volumeTolerance__ml      = {absolute = 0.5, percent = 10 }
local rateTolerance__bpm       = {absolute = 1. , percent = 0  }
local oxygen                   = {absolute = 0 , percent = 3  }

local function delay_sec(xSecond)  
    local clock = os.clock
    local t0 = clock()
    while (clock() - t0) <= xSecond do end
end

local alarm = 
{
	AL_NONE = 0,                               --[[ No alarm  ]]
	--Power Alarm                              
	AL_Accu_Empty                        = 1,  --[[Alarm Accu Empty ]]
	--System failure                           
	AL_SysFail_AUDIO                     = 2,  --[[ Alarm Acoustic Audio Test Fail  ]]
	AL_SysFail_ChecksumConPIC            = 3,  --[[ Alarm Checksum error Controller PIC  ]]
	AL_SysFail_ChecksumMonPIC            = 4,  --[[ Alarm  Checksum error Monitor PIC  ]]
	AL_SysFail_RELAIS_DEFECT             = 5,  --[[ Alarm Relais defect  ]]
	--AL_SysFail_P_PROXIMAL,		       		  
	AL_SysFail_P_IN_MIXER                = 6,  --[[ Alarm Input pressure blender  ]]
	AL_SysFail_VOLTAGE                   = 7,  --[[ Alarm Voltage monitoring  ]]
	AL_SysFail_IF_SPI                    = 8,  --[[ Alarm SPI interface  ]]
	AL_SysFail_IF_DIO                    = 9,  --[[ Alarm DIO interface  ]]
	AL_SysFail_IF_COM                    = 10, --[[ Alarm COM interface  ]]
	AL_SysFail_IF_I2C                    = 11, --[[ Alarm I2C interface  ]]
	AL_SysFail_IF_PIF                    = 12, --[[ Alarm PIF (Parallel interface) interface  ]]
	--AL_SysFail_IF_ACULINK  		           --[[ Alarm AcuLink interface  ]]
	AL_SysFail_OUTOFMEMORY               = 13, --[[ Alarm Low physical memory  ]]
	AL_SysFail_Fan                       = 14, --[[ Alarm Coolingfan defect  ]]
	--AL_SysFail_IF_CO2  			       	   --[[ Alarm CO2 interface  ]]
	AL_SysFail_MIXER_AVCAL               = 15, --[[ Alarm Blender defect or Exhalation calibration  ]]
	AL_Accu_Defect                       = 16, --[[ Alarm Accu defect  ]]
	--System alarms                          
	AL_SysAl_P_IN_O2                     = 17, --[[ Alarm Oxygen supply pressure  ]]
	AL_SysAl_P_IN_AIR                    = 18, --[[ Alarm Air supply pressure  ]]
	--AL_SysAl_P_EXSPIRATIONTUBE, 	      	
	--AL_SysAl_P_INSPIRATIONTUBE, 	      	
	AL_SysAl_TUBE_OCCLUSION              = 19, --[[ Alarm Tube Occlusion  ]]
	--Disconecction Alarms               
	AL_DISCONNECTION                     = 20, --[[ Alarm Patient disconnected  ]]
	--Tubus Alarms                       
	AL_TUBUSBLOCKED                      = 21, --[[ Alarm check ET tube  ]]
	--Sensor Alarms
	AL_Sens_FLOW_SENSOR_DEFECT           = 22, --[[ Alarm Flow sensor defect  ]]
	AL_Sens_FLOW_SENSOR_CLEANING         = 23, --[[ Alarm Clean flow sensor  ]]
	AL_Sens_FLOW_SENSOR_NOTCONNECTED     = 24, --[[ Alarm Flow sensor not connected  ]]
	AL_Sens_FLOW_SENSOR_NOT_CALIBRATED   = 25,
	AL_Sens_O2_SENSOR_DEFECT             = 26, --[[ Alarm Oxygen sensor defect  ]]
	AL_Sens_O2_SENSOR_USED               = 27, --[[ Alarm Oxygen sensor used up  ]]
	AL_Sens_O2_VALUE_INCORRECT           = 28, --[[ Alarm O2 value out of range  ]]
	AL_Sens_O2_NOT_CALIBRATED            = 29, --[[ Alarm O2 sensor not calibrated  ]]
	AL_Sens_PRICO_FiO2outOfRange         = 30, --[[ Alarm FiO2 out of range  ]]
	--CO2Sensor
	AL_Sens_CO2_MODULE_NOTCONNECTED      = 31, --[[ Alarm CO2 module disconnected  ]]
	AL_Sens_CO2_FILTERLINE_NOTCONNECTED  = 32, --[[ Alarm CO2 FilterLine disconnected  ]]
	AL_Sens_CO2_CHECKSAMPLINGLINE        = 33, --[[ Alarm check CO2 sampling line  ]]
	AL_Sens_CO2_CHECKAIRWAYADAPTER       = 34, --[[ Alarm check CO2 airway adapter  ]]
	AL_Sens_CO2_SENSORFAULTY             = 35, --[[ Alarm CO2 sensor faulty  ]]
	--SPO2 Sensor                        
	AL_Sens_SPO2_MODULE_NOTCONNECTED     = 36, --[[ Alarm SPO2 module disconnected  ]]
	AL_Sens_SPO2_SENSORFAULTY            = 37, --[[ Alarm SPO2 sensoir failure  ]]
	AL_Sens_SPO2_CHECKSENSOR             = 38, --[[ Alarm SPO2 check sensor  ]]
	--Nebulizer
	--AL_Nebulizer_Disconnection,			   --[[ Alarm Nebulizer disconnected  ]]
	--AL_Nebulizer_SysError,				   --[[ Alarm Nebulizer ERROR  ]]
	--Patient alarms
	AL_PRICO_FiO2max                     = 39, --[[ Alarm maximum FiO2  ]]
	AL_PRICO_FiO2min                     = 40, --[[ Alarm minimum FiO2  ]]
	AL_PatAl_SPO2_SIQmin                 = 41, --[[ Alarm minimum SIQe  ]]
	AL_PatAl_MVmax                       = 42, --[[ Alarm High minute volume  ]]
	AL_PatAl_MVmin                       = 43, --[[ Alarm Low minute volume  ]]
	AL_PatAl_PIPmax                      = 44, --[[ Alarm Pressure PIP too high  ]]
	AL_PatAl_PIPmin                      = 45, --[[ Alarm Pressure PIP too low  ]]
	AL_PatAl_PEEPminLow                  = 46, --[[ Alarm Low PEEP alarm  ]]
	AL_PatAl_PEEPminHigh                 = 47, --[[ Alarm High PEEP alarm  ]]
	AL_PatAl_BPMmax                      = 48, --[[ Alarm High breath rate  ]]
	AL_PatAl_Leakmax                     = 49, --[[ Alarm High tube leak  ]]
	AL_PatAl_Apnoe                       = 50, --[[ Alarm Apnea alarm  ]]
	AL_PatAl_DCO2max                     = 51, --[[ Alarm High DCO2 alarm  ]]
	AL_PatAl_DCO2min                     = 52, --[[ Alarm Low DCO2 alarm  ]]
	AL_PatAl_ETCO2max                    = 53, --[[ Alarm High ETCO2 alarm  ]]
	AL_PatAl_ETCO2min                    = 54, --[[ Alarm Low ETCO2 alarm  ]]
	AL_PatAl_FICO2max                    = 55, --[[ Alarm High FICO2 alarm  ]]
	AL_PatAl_FICO2min                    = 56, --[[ Alarm Low FICO2 alarm  ]]
	AL_PatAl_SPO2max                     = 57, --[[ Alarm High SPO2 alarm 53 ]]
	AL_PatAl_SPO2min                     = 58, --[[ Alarm Low SPO2 alarm 54 ]]
	AL_PatAl_PulseRatemax                = 59, --[[ Alarm High Pulse Rate alarm  ]]
	AL_PatAl_PulseRatemin                = 60, --[[ Alarm Low Pulse Rate alarm ]]
	AL_PatAl_SPO2_PImin                  = 61, --[[ Alarm Low SpO2 Perfusion Index alarm 57 ]]
	AL_PatAl_MAPmax                      = 62, --[[ Alarm High MAP alarm  ]]
	AL_PatAl_MAPmin                      = 63, --[[ Alarm Low MAP alarm  ]]
	--SysLimit Alarms                   
	AL_SysLimit_Pinsp_NotReached         = 64, --[[ Alarm Inspiratory pressure not reached  ]]
	AL_SysLimit_Vlimitted                = 65, --[[ Alarm Tidal Volume limited  ]]
	AL_SysLimit_Vgaranty                 = 66, --[[ Alarm Tidal Volume not reached  ]]
	--akku alarms                       
	AL_Accu_POWER                        = 66, --[[ Alarm Power failure  ]]
	AL_Accu_60                           = 67, --[[ Alarm Charge battery (<60min)  ]]
	AL_Accu_30                           = 68, --[[ Alarm Charge battery (<30min)  ]]
	AL_Accu_15                           = 69, --[[ Alarm Charge battery (<15min)  ]]
}

--------------------------------------------------------------------------------
-- Publish Public Interface
--------------------------------------------------------------------------------
pubFTI = {
    ventMode                             = ventMode                ,
    riseControl                          = riseControl             ,
    ModeOption1                          = ModeOption1             ,
    ModeOption2                          = ModeOption2             ,
    patientSize                          = patientSize             ,
    onOffState                           = onOffState              ,
	pressureTolerance__cmH2O             = pressureTolerance__cmH2O,
	flowTolerance__lpm                   = flowTolerance__lpm      ,
	volumeTolerance__ml                  = volumeTolerance__ml     ,
	rateTolerance__bpm                   = rateTolerance__bpm      ,
	oxygen                               = oxygen                  ,
    delay_sec                            = delay_sec               ,
	alarm                                = alarm                   ,
}

return pubFTI