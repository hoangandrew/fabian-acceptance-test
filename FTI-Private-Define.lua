------------------------------------------------------------------------------
-- (c) Copyright 2019 Vyaire Medial, or one of its subsidiaries.
--     All Rights Reserved.
------------------------------------------------------------------------------
-- Private Define fabian Terminal Interface
------------------------------------------------------------------------------

--pubFTI = require "FTI-Public-Define"

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

local errorValue = {
    TERMINAL_NOTVALID      = 32771,  -- -32765 after converted to signed
	TERM_PARAM_NOSUPPORT   = 0xFD,
    TERM_PARAM_OUTOFFRANGE = 0xFF,
}

local hfoFreqRecCondition = {
    HFOFreqRec1            =    60,
    HFOFreqRec2            =   120,
    HFOFreqRec3            =   180,
	HFOFreqRec4            =   240,  
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
    etCO2                      = 100,
    InspTimePSV                = 1000,
    MinuteVolume               = 1000,
    Flow                       = 1000,
    PerfusionIndex             = 1000,
    Time                       = 1000,
    Trigger                    = 2580,
    }
	
local continuousRespond = {
    TERM_MEASUREMENTS_BTB                = 0x00, 
    TERM_MEASUREMENTS_AVG                = 0x02, 
} 
local SOM = {
    TERM_MSG_SOM                         = 0x02,
}

local command = {

    TERM_GET_MEASUREMENTS_ONCE_BTB       = 0x00,
    TERM_GET_MEASUREMENTS_CONTINIOUS_BTB = 0x01,
    TERM_GET_MEASUREMENTS_ONCE_AVG       = 0x02,
    TERM_GET_MEASUREMENTS_CONTINIOUS_AVG = 0x03,
    TERM_GET_WAVE_DATA                   = 0x04,
    TERM_GET_VENT_MODE                   = 0x05,
    TERM_GET_MODE_OPTION1                = 0x06,
    TERM_GET_MODE_OPTION2                = 0x07,
	TERM_STOP_CONTINUOUS_MEASUREMENTS    = 0x50,
    TERM_STOP_WAVE_DATA                  = 0x51,
}

local def = {
    mode        = { minimum = pubFTI.ventMode.IPPV       , maximum = pubFTI.ventMode.O2Therapy    , scale = nil },
	IE 			= { minimum = 0				             , maximum = 2                            , scale = nil },
	RiseControl = { minimum = pubFTI.riseControl.iFlow   , maximum = 2                            , scale = nil },
	HFOFreqRec  = { minimum = 0                          , maximum = 60                           , scale = nil },
	HFOFlow     = { minimum = 5                          , maximum = 20                           , scale = 1000 },
	LeakComp    = { minimum = 0                          , maximum = 3                            , scale = nil },
	PInspPress  = { minimum = 4                          , maximum = 80                           , scale = 10 },
	PEEP        = { minimum = 0                          , maximum = 30                           , scale = 10 },
	PPSV        = { minimum = 2                          , maximum = 80                           , scale = 10 },
	HFOAmp      = { minimum = 5                          , maximum = 100                          , scale = 10 },
	HFOAmpMAX   = { minimum = 5                          , maximum = 100                          , scale = 10 },
	HFOFreq     = { minimum = 5                          , maximum = 20                           , scale = 1 },
	O2          = { minimum = 21                         , maximum = 100                          , scale = nil },
	Flow        = { minimum = 1                          , maximum = 32                           , scale = 1000 },
	RiseTime    = { minimum = 0.1                        , maximum = 2                            , scale = 1000 },
	ITime       = { minimum = 1                          , maximum = 2                            , scale = 1000 },
	ETime       = { minimum = 0.2                        , maximum = 30                           , scale = 1000 },
	HFOPMean    = { minimum = 7                          , maximum = 50                           , scale = 10 },
	VLimit      = { minimum = 1                          , maximum = 150                          , scale = 10 },
	VGuarantee  = { minimum = 0.8                        , maximum = 60                           , scale = 10 },
	AbortPSV    = { minimum = 1                          , maximum = 85                           , scale = nil },
	TherapyFlow = { minimum = 0                          , maximum = 15                           , scale = 1000 },
	Trigger     = { minimum = 1                          , maximum = 10                           , scale = 2580 },
	FlowMin     = { minimum = 4                          , maximum = 16                           , scale = 1000 },
	CPAP        = { minimum = 1                          , maximum = 30                           , scale = 10 },
	PManuel     = { minimum = 1                          , maximum = 80                           , scale = 10 },
	Backup      = { minimum = 0                          , maximum = 5                            , scale = nil },
	ITimeRec    = { minimum = 2                          , maximum = 13                           , scale = 1000 },
	ETimeRec    = { minimum = 0                          , maximum = 160                          , scale = 1000 },
	O2Flush     = { minimum = 23                         , maximum = 100                          , scale = nil },
	SPO2Low     = { minimum = 0                          , maximum = 98                           , scale = nil },
	SPO2High    = { minimum = 1                          , maximum = 100                          , scale = nil },
	FIO2High    = { minimum = 1                          , maximum = 100                          , scale = nil },
	FIO2Low     = { minimum = 0                          , maximum = 98                           , scale = nil },
	onOffState  = { minimum = pubFTI.onOffState.OFF      , maximum = pubFTI.onOffState.ON         , scale = nil },
	VentRange   = { minimum = pubFTI.patientSize.NEONATAL, maximum = pubFTI.patientSize.PEDIATRIC , scale = nil },
	}

--------------------------------------------------------------------------------
-- Publish Public Interface
--------------------------------------------------------------------------------
priFTI = {
    para_get_VentSettings                = para_get_VentSettings   ,
    para_set_settingData                 = para_set_settingData    ,
    para_measure_response                = para_measure_response   ,
    para_get_waveData                    = para_get_waveData       ,
    command                              = command                 ,
    measuredData_ScaleFactor             = measuredData_ScaleFactor,
	errorValue                           = errorValue              ,
	hfoFreqRecCondition                  = hfoFreqRecCondition     ,
	continuousRespond                    = continuousRespond       ,
	SOM                                  = SOM                     ,
	def                                  = def                     ,
}

return priFTI
