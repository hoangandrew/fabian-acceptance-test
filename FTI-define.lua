------------------------------------------------------------------------------
-- (c) Copyright 2019 Vyaire Medial, or one of its subsidiaries.
--     All Rights Reserved.
------------------------------------------------------------------------------
-- Define fabian Terminal Interface
------------------------------------------------------------------------------

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

local para_get_VentSettings = {
    TERMINAL_GET_VENT_RUNSTATE           = 0x09,
    TERMINAL_GET_STATE_VLimit            = 0x0A,
    TERMINAL_GET_STATE_VGarant           = 0x0B,
    TERMINAL_GET_PARAM_VentRange         = 0x0C,
    TERMINAL_GET_PARAM_IERatioHFO        = 0x0D,
    TERMINAL_GET_MANBREATHrunning        = 0x0E,
    TERMINAL_GET_PressureRiseCtrl        = 0x0F,
    TERMINAL_GET_PARAM_HFOFreqRec        = 0x10,
    TERMINAL_GET_PARAM_HFOFlow           = 0x11,
    TERMINAL_GET_LeakCompensation        = 0x12,
    TERMINAL_GET_TriggerOption           = 0x13,
    TERMINAL_GET_FOToscillationState     = 0x14,
    TERMINAL_GET_PARAM_PINSP             = 0x15,
    TERMINAL_GET_PARAM_PEEP              = 0x16,
    TERMINAL_GET_PARAM_PPSV              = 0x17,
    TERMINAL_GET_PARAM_BPM               = 0x18,
    TERMINAL_GET_PARAM_HFAmpl            = 0x19,
    TERMINAL_GET_PARAM_HFAmplMax         = 0x1A,
    TERMINAL_GET_PARAM_HFFreq            = 0x1B,
    TERMINAL_GET_PARAM_O2                = 0x1C,
    TERMINAL_GET_PARAM_IFlow             = 0x1D,
    TERMINAL_GET_PARAM_EFlow             = 0x1E,
    TERMINAL_GET_PARAM_Risetime          = 0x1F,
    TERMINAL_GET_PARAM_ITime             = 0x20,
    TERMINAL_GET_PARAM_ETime             = 0x21,
    TERMINAL_GET_PARAM_HFPMean           = 0x22,
    TERMINAL_GET_PARAM_HFPMeanRec        = 0x23,
    TERMINAL_GET_PARAM_VLimit            = 0x24,
    TERMINAL_GET_PARAM_VGarant           = 0x25,
    TERMINAL_GET_PARAM_AbortCriterionPSV = 0x26,
    TERMINAL_GET_PARAM_TherapieFlow      = 0x27,
    TERMINAL_GET_PARAM_Trigger           = 0x28,
    TERMINAL_GET_PARAM_Flowmin           = 0x29,
    TERMINAL_GET_PARAM_CPAP              = 0x2A,
    TERMINAL_GET_PARAM_PManual           = 0x2B,
    TERMINAL_GET_PARAM_Backup            = 0x2C,
    TERMINAL_GET_PARAM_ITimeRec          = 0x2D,
    TERMINAL_GET_PARAM_ETIMERec          = 0x2E,
    TERMINAL_GET_PARAM_SPO2LOW           = 0x2F,
    TERMINAL_GET_PARAM_SPO2HIGH          = 0x30,
    TERMINAL_GET_PARAM_FIO2LOW           = 0x31,
    TERMINAL_GET_PARAM_FIO2HIGH          = 0x32,
    TERMINAL_GET_STATE_PRICO             = 0x33,
}

local para_set_settingData = {
    TERMINAL_SET_VENT_MODE               = 0x52,
    TERMINAL_SET_VENT_RUNSTATE           = 0x55,
    TERMINAL_SET_STATE_VLimit            = 0x56,
    TERMINAL_SET_STATE_VGarant           = 0x57,
    TERMINAL_SET_PARAM_VentRange         = 0x58,
    TERMINAL_SET_PARAM_IERatioHFO        = 0x59,
    TERMINAL_SET_MANBREATHrunning        = 0x5A,
    TERMINAL_SET_PressureRiseCtrl        = 0x5B,
    TERMINAL_SET_PARAM_HFOFreqRec        = 0x5C,
    TERMINAL_SET_PARAM_HFOFlow           = 0x5D,
    TERMINAL_SET_LeakCompensation        = 0x5E,
    TERMINAL_SET_PARAM_PINSP             = 0x60,
    TERMINAL_SET_PARAM_PEEP              = 0x61,
    TERMINAL_SET_PARAM_PPSV              = 0x62,
    TERMINAL_SET_PARAM_BPM               = 0x63,
    TERMINAL_SET_PARAM_HFAmpl            = 0x64,
    TERMINAL_SET_PARAM_HFAmplMax         = 0x65,
    TERMINAL_SET_PARAM_HFFreq            = 0x66,
    TERMINAL_SET_PARAM_O2                = 0x67,
    TERMINAL_SET_PARAM_IFlow             = 0x68,
    TERMINAL_SET_PARAM_EFlow             = 0x6A,
    TERMINAL_SET_PARAM_RiseTime          = 0x6B,
    TERMINAL_SET_PARAM_ITime             = 0x6C,
    TERMINAL_SET_PARAM_ETime             = 0x6D,
    TERMINAL_SET_PARAM_HFPMean           = 0x6E,
    TERMINAL_SET_PARAM_HFPMeanRec        = 0x6F,
    TERMINAL_SET_PARAM_VLimit            = 0x70,
    TERMINAL_SET_PARAM_VGarant           = 0x71,
    TERMINAL_SET_PARAM_AbortCriterionPSV = 0x72,
    TERMINAL_SET_PARAM_TherapieFlow      = 0x73,
    TERMINAL_SET_PARAM_Trigger           = 0x74,
    TERMINAL_SET_PARAM_Flowmin           = 0x75,
    TERMINAL_SET_PARAM_CPAP              = 0x76,
    TERMINAL_SET_PARAM_PManual           = 0x77,
    TERMINAL_SET_PARAM_Backup            = 0x78,
    TERMINAL_SET_PARAM_ITimeRec          = 0x79,
    TERMINAL_SET_PARAM_O2_FLUSH          = 0x7A,
    TERMINAL_SET_PARAM_SPO2LOW           = 0x7B,
    TERMINAL_SET_PARAM_SPO2HIGH          = 0x7C,
    TERMINAL_SET_PARAM_FIO2LOW           = 0x7D,
    TERMINAL_SET_PARAM_FIO2HIGH          = 0x7E,
    TERMINAL_SET_STATE_PRICO             = 0x7F,
}

local para_measure_response = {
    None              =  0,
    ActiveVentMode    =  4,
    Pmax              =  5,  -- Peak Pressure
    Pmitt             =  7,  -- Mean Pressure
    PEEP              =  9,  -- PEEP
    DynamicCompliance = 11,  -- Dynamic Compliance
    C20C              = 13,  -- Overextension Index C20/C
    Resistance        = 15,  -- Ventilatory Resistance
    MV                = 17,  -- Minute Volume
    TVI               = 19,  -- Insp. Mand. Tidal Volume
    TVE               = 21,  -- Exp. Mand. Tidal Volume
    TVEresp           = 23,  -- Exp. Mand. TV Respirator
    TVEpat            = 25,  -- Exp. Mand. TV Patient
    HFAmpl            = 27,  -- HF Amplitude
    TVEHFO            = 29,  -- HF Exp. Mand. Tidal Volume
    DCO2              = 31,  -- Gas Transport Coefficient
    TrigVol           = 33,  -- Trigger Volume/Trigger Flow
    ITimePSV          = 35,  -- Inspiratory Time PSV
    SPO2              = 37,  -- SPO2
    PulseRate         = 39,  -- Pulse Rate
    PerfusionIndex    = 41,  -- Perfusion Index
    ETCO2             = 43,  -- ETCO2
    BPM               = 45,  -- Respiratory Rate
    BPMco2            = 47,  -- Respiratory Rate etCO2 Module
    Leak              = 49,  -- Leakage
    HFFreq            = 51,  -- HF Rate
    Percent           = 53,  -- Share MV Respirator
    OxyVal            = 55,  -- FiO2	
    INSP_FLOW         = 57,  -- Inspiratory Flow
    EXP_FLOW          = 59,
    DEMAND_FLOW       = 61,
}

local para_get_waveData = {
    Pressure = 3,
    Flow     = 5,
    etCO2    = 7,
}

local range = {
    modeMIN                =     1,
    modeMAX                =    10,
    OFF                    =     0,
    ON                     =     1,
    NEONATAL               =     1,
    PEDIATRIC              =     2,
    IEMIN                  =     0,
    IEMAX                  =     2,
    RiseControlMIN         =     0,
    RiseControlMAX         =     1,
    HFOFreqRecMIN          =     0,
    HFOFreqRec1            =    60,
    HFOFreqRec1Half        =    90,
    HFOFreqRec2            =   120,
    HFOFreqRec2Half        =   150,
    HFOFreqRec3            =   180,
    HFOFreqRec3Half        =   210,
    HFOFreqRecMAX          =   240,   
    HFOFlowMIN             =     5,
    HFOFlowMAX             =    20,
    LeakCompMIN            =     0,
    LeakCompMAX            =     3,
    PInspPressMIN          =     4,
    PInspPressMAX          =    80,
    PEEPMIN                =     0,
    PEEPMAX                =    30,    
    PPSVMIN                =     2,
    PPSVMAX                =    80,    
    HFOAmpMIN              =     5,
    HFOAmpMAX              =   100,   
    HFOFreqMIN             =     5,
    HFOFreqMAX             =    20,
    O2MIN                  =    21,
    O2MAX                  =   100,
    FlowMIN                =     1,
    FlowMAX                =    32,        
    RiseTimeMIN            =     0.1,
    RiseTimeMAX            =     2, 
    ITimeMIN               =     1,
    ITimeMAX               =     2, 
    ETimeMIN               =     0.2,
    ETimeMAX               =    30,    
    HFOPMeanMIN            =     7,
    HFOPMeanMAX            =    50,    
    VLimitMIN              =     1,
    VLimitMAX              =   150,   
    VGuaranteeMIN          =     0.8,
    VGuaranteeMAX          =    60,    
    AbortPSVMIN            =     1,
    AbortPSVMAX            =    85,    
    TherapyFlowMIN         =     0,
    TherapyFlowMAX         =    15,
    TriggerMIN             =     1,
    TriggerMAX             =    10,    
    FlowMinuteMIN          =     4,
    FlowMinuteMAX          =    16,
    CPAPMIN                =     1,
    CPAPMAX                =    30,    
    PManuelMIN             =     1,
    PManuelMAX             =    80,    
    BackupMIN              =     0,
    BackupMAX              =     5, 
    ITimeRecMIN            =     0,
    ITimeRecMAX            =   160,
    ETimeRecMIN            =     0,
    ETimeRecMAX            =   160,   
    O2FlushMIN             =    23,
    O2FlushMAX             =   100,   
    SPO2LowMIN             =     0,
    SPO2LowMAX             =    98,    
    SPO2HighMIN            =     1,
    SPO2HighMAX            =   100,   
    FIO2LowMIN             =     0,
    FIO2LowMAX             =    98,    
    FIO2HighMIN            =     1,
    FIO2HighMAX            =   100,   
    MissingValueLOW        =    32.771,
    MissingValueMID        =  3277.1,
    MissingValueHIGH       = 32771,
    }

local measuredData_ScaleFactor = {
    Pressure                   = 10,
    PPSVS                      = 10,
    Vol                        = 10,
    Peep                       = 10,
    SPO2                       = 10,
    CPAP                       = 10,
    PManuel                    = 10,
    DynamicCompliance          = 10,
    OverextensionIndex         = 10,
    VentilatoryResistance      = 10,
    MandatoryTidal             = 10,
    TriggerVolumeFlow          = 10,
    HFOAmp                     = 10,
    FIO2                       = 10,
    etCO2                      = 10,
    InspTimePSV                = 1000,
    MinuteVolume               = 1000,
    Flow                       = 1000,
    PerfusionIndex             = 1000,
    Time                       = 1000,
    Trigger                    = 2580,
    }

local command = {
    TERM_STOP_CONTINUOUS_MEASUREMENTS    = 0x50,
    TERM_STOP_WAVE_DATA                  = 0x51,
    TERM_MSG_SOM                         = 0x02,
    TERM_PARAM_NOSUPPORT                 = 0xFD,
    TERM_PARAM_OUTOFFRANGE               = 0xFF,
    TERM_GET_MEASUREMENTS_ONCE_BTB       = 0x00,
    TERM_GET_MEASUREMENTS_CONTINIOUS_BTB = 0x01,
    TERM_GET_MEASUREMENTS_ONCE_AVG       = 0x02,
    TERM_GET_MEASUREMENTS_CONTINIOUS_AVG = 0x03,
    TERM_MEASUREMENTS_BTB                = 0x00,
    TERM_MEASUREMENTS_AVG                = 0x02,
    TERM_GET_WAVE_DATA                   = 0x04,
    TERM_GET_VENT_MODE                   = 0x05,
    TERM_GET_MODE_OPTION1                = 0x06,
    TERM_GET_MODE_OPTION2                = 0x07,
    TERM_WAVE_DATA                       = 0x04,
    TERM_VENT_MODE                       = 0x05,
    TERM_MODE_OPTION1                    = 0x06,
    TERM_MODE_OPTION2                    = 0x07,
}
--------------------------------------------------------------------------------
-- Publish Public Interface
--------------------------------------------------------------------------------
FTI = {
    ventMode                             = ventMode                ,
    ModeOption1                          = ModeOption1             ,
    ModeOption2                          = ModeOption2             ,
    para_get_VentSettings                = para_get_VentSettings   ,
    para_set_settingData                 = para_set_settingData    ,
    para_measure_response                = para_measure_response   ,
    para_get_waveData                    = para_get_waveData       ,
    command                              = command                 ,
    range                                = range                   ,
    measuredData_ScaleFactor             = measuredData_ScaleFactor,
}
