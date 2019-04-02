------------------------------------------------------------------------------
-- (c) Copyright 2019 Vyaire Medial, or one of its subsidiaries.
--     All Rights Reserved.
------------------------------------------------------------------------------
-- Define fabian Terminal Interface
----------------------------------------------------------------------------------------

local ventMode = {
    eNONE      =  0,
    eIPPV      =  1,
    eSIPPV     =  2,
    eSIMV      =  3,
    eSIMVPSV   =  4,
    ePSV       =  5,
    eCPAP      =  6,
    eNCPAP     =  7,
    eDUOPAP    =  8,
    eHFO       =  9,
    eO2Therapy = 10,
    eSERVICE   = 15
}

local ModeOption1 = {
    eStartStopBit                         = 0,  -- 0=Start, 1=Stop
    eStateVolumnGuaranteeBit              = 1,  -- 0=off, 1=on
    eStateVolumnLimitBit                  = 2,  -- 0=off, 1=on
    eVentilatorRangeBit                   = 3,  -- 0=NEONATAL, 1=PEDIATRIC
    eFlowSensorCalibrationRunningBit      = 4,
    eO2CompensationEnabledBit             = 5,
    eExhalationValveCalibrationRunningBit = 6,
    eTriggerModeBit                       = 7,  -- 0=Volumetrigger, 1=Flowtrigger
    eCalibrationProcess_21_O2_RunningBit  = 8,
    eCalibrationProcess_100_O2_RunningBit = 9,
    eTubeSet_InfantFlow_MediJetBit        = 10,  -- NCPAP/DUOPAP
                                                 -- xxxx 00xx xxxx xxxx = InfantFlow
                                                 -- xxxx 01xx xxxx xxxx = MediJet
    eTubeSet_InfantFlowLPBit              = 11,  -- xxxx 10xx xxxx xxxx = InfantFlowLP
                                                 -- xxxx 11xx xxxx xxxx = others notdef
    eIERatioHFOBit11                      = 12,  -- Bit 12+13: I:E Ratio HFO:
                                                 -- xx00 xxxx xxxx xxxx = 1:3
                                                 -- xx01 xxxx xxxx xxxx = 1:2
    eIERatioHFOBit12                      = 13,  -- xx10 xxxx xxxx xxxx = 1:1
                                                 -- xx11 xxxx xxxx xxxx = others notdef
    eInternalUseBit                       = 14,
    eManualBreathRunningBit               = 15
}

local ModeOption2 = {
    ePressureRiseControlBit0  = 0,          -- xxxx xx00 = I-Flow
    ePressureRiseControlBit1  = 1,          -- xxxx xx01 = 01=Ramp
                                            -- xxxx xx10 = AutoIFlow
                                            -- xxxx xx11 = others notdef
    eHFORecruitmentBit        = 2,          -- 0=off, 1==on
    eHFOFlowBit               = 3,          -- 0=off, 1==on
    eReservedBit              = 4,          -- not used
    eBiasFlowBit              = 5,          -- 0==internal, 1 == external
    eTriggerModeBit6          = 6,          -- xxx0 00xx xxxx = volume trigger
    eTriggerModeBit7          = 7,          -- xxx0 01xx xxxx = flow trigger
    eTriggerModeBit8          = 8,          -- xxx0 10xx xxxx = pressure trigger
                                            -- xxx0 xxxx xxxx = for future setting
    eFOTOscillationRunningBit = 9,         
    eLeakCompensationBit10    = 10,         -- 00xx xxxx xxxx = off
    eLeakCompensationBit11    = 11,         -- 01xx xxxx xxxx = low
                                            -- 10xx xxxx xxxx = middle
                                            -- 11xx xxxx xxxx = high
}

local para_get_VentSettings = {
    eTERMINAL_GET_VENT_RUNSTATE           = 0x09,
    eTERMINAL_GET_STATE_VLimit            = 0x0A,
    eTERMINAL_GET_STATE_VGarant           = 0x0B,
    eTERMINAL_GET_PARAM_VentRange         = 0x0C,
    eTERMINAL_GET_PARAM_IERatioHFO        = 0x0D,
    eTERMINAL_GET_MANBREATHrunning        = 0x0E,
    eTERMINAL_GET_PressureRiseCtrl        = 0x0F,
    eTERMINAL_GET_PARAM_HFOFreqRec        = 0x10,
    eTERMINAL_GET_PARAM_HFOFlow           = 0x11,
    eTERMINAL_GET_LeakCompensation        = 0x12,
    eTERMINAL_GET_TriggerOption           = 0x13,
    eTERMINAL_GET_FOToscillationState     = 0x14,
    eTERMINAL_GET_PARAM_PINSP             = 0x15,
    eTERMINAL_GET_PARAM_PEEP              = 0x16,
    eTERMINAL_GET_PARAM_PPSV              = 0x17,
    eTERMINAL_GET_PARAM_BPM               = 0x18,
    eTERMINAL_GET_PARAM_HFAmpl            = 0x19,
    eTERMINAL_GET_PARAM_HFAmplMax         = 0x1A,
    eTERMINAL_GET_PARAM_HFFreq            = 0x1B,
    eTERMINAL_GET_PARAM_O2                = 0x1C,
    eTERMINAL_GET_PARAM_IFlow             = 0x1D,
    eTERMINAL_GET_PARAM_EFlow             = 0x1E,
    eTERMINAL_GET_PARAM_Risetime          = 0x1F,
    eTERMINAL_GET_PARAM_ITime             = 0x20,
    eTERMINAL_GET_PARAM_ETime             = 0x21,
    eTERMINAL_GET_PARAM_HFPMean           = 0x22,
    eTERMINAL_GET_PARAM_HFPMeanRec        = 0x23,
    eTERMINAL_GET_PARAM_VLimit            = 0x24,
    eTERMINAL_GET_PARAM_VGarant           = 0x25,
    eTERMINAL_GET_PARAM_AbortCriterionPSV = 0x26,
    eTERMINAL_GET_PARAM_TherapieFlow      = 0x27,
    eTERMINAL_GET_PARAM_Trigger           = 0x28,
    eTERMINAL_GET_PARAM_Flowmin           = 0x29,
    eTERMINAL_GET_PARAM_CPAP              = 0x2A,
    eTERMINAL_GET_PARAM_PManual           = 0x2B,
    eTERMINAL_GET_PARAM_Backup            = 0x2C,
    eTERMINAL_GET_PARAM_ITimeRec          = 0x2D,
    eTERMINAL_GET_PARAM_ETIMERec          = 0x2E,
    eTERMINAL_GET_PARAM_SPO2LOW           = 0x2F,
    eTERMINAL_GET_PARAM_SPO2HIGH          = 0x30,
    eTERMINAL_GET_PARAM_FIO2LOW           = 0x31,
    eTERMINAL_GET_PARAM_FIO2HIGH          = 0x32,
    eTERMINAL_GET_STATE_PRICO             = 0x33,
}

local para_set_settingData = {
    eTERMINAL_SET_VENT_RUNSTATE           = 0x55,
    eTERMINAL_SET_STATE_VLimit            = 0x56,
    eTERMINAL_SET_STATE_VGarant           = 0x57,
    eTERMINAL_SET_PARAM_VentRange         = 0x58,
    eTERMINAL_SET_PARAM_IERatioHFO        = 0x59,
    eTERMINAL_SET_MANBREATHrunning        = 0x5A,
    eTERMINAL_SET_PressureRiseCtrl        = 0x5B,
    eTERMINAL_SET_PARAM_HFOFreqRec        = 0x5C,
    eTERMINAL_SET_PARAM_HFOFlow           = 0x5D,
    eTERMINAL_SET_LeakCompensation        = 0x5E,
    eTERMINAL_SET_PARAM_PINSP             = 0x60,
    eTERMINAL_SET_PARAM_PEEP              = 0x61,
    eTERMINAL_SET_PARAM_PPSV              = 0x62,
    eTERMINAL_SET_PARAM_BPM               = 0x63,
    eTERMINAL_SET_PARAM_HFAmpl            = 0x64,
    eTERMINAL_SET_PARAM_HFAmplMax         = 0x65,
    eTERMINAL_SET_PARAM_HFFreq            = 0x66,
    eTERMINAL_SET_PARAM_O2                = 0x67,
    eTERMINAL_SET_PARAM_IFlow             = 0x68,
    eTERMINAL_SET_PARAM_EFlow             = 0x6A,
    eTERMINAL_SET_PARAM_RiseTime          = 0x6B,
    eTERMINAL_SET_PARAM_ITime             = 0x6C,
    eTERMINAL_SET_PARAM_ETime             = 0x6D,
    eTERMINAL_SET_PARAM_HFPMean           = 0x6E,
    eTERMINAL_SET_PARAM_HFPMeanRec        = 0x6F,
    eTERMINAL_SET_PARAM_VLimit            = 0x70,
    eTERMINAL_SET_PARAM_VGarant           = 0x71,
    eTERMINAL_SET_PARAM_AbortCriterionPSV = 0x72,
    eTERMINAL_SET_PARAM_TherapieFlow      = 0x73,
    eTERMINAL_SET_PARAM_Trigger           = 0x74,
    eTERMINAL_SET_PARAM_Flowmin           = 0x75,
    eTERMINAL_SET_PARAM_CPAP              = 0x76,
    eTERMINAL_SET_PARAM_PManual           = 0x77,
    eTERMINAL_SET_PARAM_Backup            = 0x78,
    eTERMINAL_SET_PARAM_ITimeRec          = 0x79,
    eTERMINAL_SET_PARAM_O2_FLUSH          = 0x7A,
    eTERMINAL_SET_PARAM_SPO2LOW           = 0x7B,
    eTERMINAL_SET_PARAM_SPO2HIGH          = 0x7C,
    eTERMINAL_SET_PARAM_FIO2LOW           = 0x7D,
    eTERMINAL_SET_PARAM_FIO2HIGH          = 0x7E,
    eTERMINAL_SET_STATE_PRICO             = 0x7F,
}

local para_measure_response = {
    eNone                     =  0,
    eActiveVentMode           =  1,
    ePmax_HIBYTE              =  2,  -- Peak Pressure
    ePmax_LOBYTE              =  3,
    ePmitt_HIBYTE             =  4,  -- Mean Pressure
    ePmitt_LOBYTE             =  5,
	ePEEP_HIBYTE              =  6,  -- PEEP
	ePEEP_LOBYTE              =  7,
	eDynamicCompliance_HIBYTE =  8,  -- Dynamic Compliance
	eDynamicCompliance_LOBYTE =  9,
    eC20C_HIBYTE              = 10,  -- Overextension Index C20/C
    eC20C_LOBYTE              = 11,
	eResistance_HIBYTE        = 12,  -- Ventilatory Resistance
	eResistance_LOBYTE        = 13,
    eMV_HIBYTE                = 14,  -- Minute Volume
	eMV_LOBYTE                = 15,
    eTVI_HIBYTE               = 16,  -- Insp. Mand. Tidal Volume
    eTVI_LOBYTE               = 17,
    eTVE_HIBYTE               = 18,  -- Exp. Mand. Tidal Volume
    eTVE_LOBYTE               = 19,
	eTVEresp_HIBYTE           = 20,  -- Exp. Mand. TV Respirator
	eTVEresp_LOBYTE           = 21,
	eTVEpat_HIBYTE            = 22,  -- Exp. Mand. TV Patient
	eTVEpat_LOBYTE            = 23,
	eHFAmpl_HIBYTE            = 24,  -- HF Amplitude
	eHFAmpl_LOBYTE            = 25,
	eTVEHFO_HIBYTE            = 26,  -- HF Exp. Mand. Tidal Volume
	eTVEHFO_LOBYTE            = 27,
	eDCO2_HIBYTE              = 28,  -- Gas Transport Coefficient
	eDCO2_LOBYTE              = 29,
	eTrigVol_HIBYTE           = 30,  -- Trigger Volume/Trigger Flow
	eTrigVol_LOBYTE           = 31,
	eITimePSV_HIBYTE          = 32,  -- Inspiratory Time PSV
	eITimePSV_LOBYTE          = 33,
	eSPO2_HIBYTE              = 34,  -- SPO2
	eSPO2_LOBYTE              = 35,
	ePulseRate_HIBYTE         = 36,  -- Pulse Rate
	ePulseRate_LOBYTE         = 37,
	ePerfusionIndex_HIBYTE    = 38,  -- Perfusion Index
	ePerfusionIndex_LOBYTE    = 39,
	eETCO2_HIBYTE             = 40,  -- ETCO2
	eETCO2_LOBYTE             = 41,
	eBPM_HIBYTE               = 42,  -- Respiratory Rate
	eBPM_LOBYTE               = 43,
	eBPMco2_HIBYTE            = 44,  -- Respiratory Rate etCO2 Module
	eBPMco2_LOBYTE            = 45,
	eLeak_HIBYTE              = 46,  -- Leakage
	eLeak_LOBYTE              = 47,
	eHFFreq_HIBYTE            = 48,  -- HF Rate
	eHFFreq_LOBYTE            = 49,
	ePercent_HIBYTE           = 50,  -- Share MV Respirator
	ePercent_LOBYTE           = 51,
	eOxyVal_HIBYTE            = 52,  -- FiO2
	eOxyVal_LOBYTE            = 53,
	eINSP_FLOW_HIBYTE         = 54,  -- Inspiratory Flow
	eINSP_FLOW_LOBYTE         = 55,
	eEXP_FLOW_HIBYTE          = 56,  -- Expiratory Flow
	eEXP_FLOW_LOBYTE          = 57,
	eDEMAND_FLOW_HIBYTE       = 58,  -- Demand Flow
	eDEMAND_FLOW_LOBYTE       = 59,
}

local para_get_waveData = {
    eValPressure_HIBYTE = 1,
    eValPressure_LOBYTE = 2,
    eValFlow_HIBYTE     = 3,
    eValFlow_LOBYTE     = 4,
    eValCO2_HIBYTE      = 5,
    eValCO2_LOBYTE      = 6,
}

local command = {
    TERM_STOP_CONTINIOUS_MEASUREMENTS    = 0x50,
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
    TERM_STOP_CONTINIOUS_MEASUREMENTS    = 0x50,
    TERM_STOP_WAVE_DATA                  = 0x51,
    TERM_MEASUREMENTS_BTB                = 0x00,
    TERM_MEASUREMENTS_AVG                = 0x02,
    TERM_WAVE_DATA                       = 0x04,
    TERM_VENT_MODE                       = 0x05,
    TERM_MODE_OPTION1                    = 0x06,
    TERM_MODE_OPTION2                    = 0x07,
}
--------------------------------------------------------------------------------
-- Publish Public Interface
--------------------------------------------------------------------------------
FTI = {
    ventMode                             = ventMode                            ,
    ModeOption1                          = ModeOption1                         ,
    ModeOption2                          = ModeOption2                         ,
    para_get_VentSettings                = para_get_VentSettings               ,
    para_set_settingData                 = para_set_settingData                ,
	para_measure_response                = para_measure_response               ,
	para_get_waveData                    = para_get_waveData                   ,
	command                              = command                             ,
}
