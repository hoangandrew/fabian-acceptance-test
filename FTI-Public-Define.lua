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
}

return pubFTI