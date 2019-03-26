------------------------------------------------------------------------------
-- (c) Copyright 2019 Vyaire Medical, or one of its subsidiaries.
--     All Rights Reserved.
------------------------------------------------------------------------------
-- Tests fabian Terminal Interface defined in FTI-define
----------------------------------------------------------------------------------------

fti = require "FTI-define"

function test_VentModeRange()
    local minMode = 1
    local maxMode = 10
    
    local isValidMode = (minMode >= FTI.ventMode.eIPPV) and (maxMode <= FTI.ventMode.eO2Therapy)
    assert(isValidMode, 'ASSERT: Vent Mode Out-of-range')

    local expectedServiceMode = 15  
    local isServiceMode = FTI.ventMode.eSERVICE == expectedServiceMode
    assert(isServiceMode, 'ASSERT: Invalid Service Mode')
end

function test_VentModes()
    test_VentModeRange()
    local expectedMode = {
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
    local mode = FTI.ventMode
    assert(mode.eNONE      == expectedMode.eNONE     , 'ASSERT: Invalid Vent Mode eNONE,      ' .. mode.eNONE     )
    assert(mode.eIPPV      == expectedMode.eIPPV     , 'ASSERT: Invalid Vent Mode eIPPV,      ' .. mode.eIPPV     )
    assert(mode.eSIPPV     == expectedMode.eSIPPV    , 'ASSERT: Invalid Vent Mode eSIPPV,     ' .. mode.eSIPPV    )
    assert(mode.eSIMV      == expectedMode.eSIMV     , 'ASSERT: Invalid Vent Mode eSIMV,      ' .. mode.eSIMV     )
    assert(mode.eSIMVPSV   == expectedMode.eSIMVPSV  , 'ASSERT: Invalid Vent Mode eSIMVPSV,   ' .. mode.eSIMVPSV  )
    assert(mode.ePSV       == expectedMode.ePSV      , 'ASSERT: Invalid Vent Mode ePSV,       ' .. mode.ePSV      )
    assert(mode.eCPAP      == expectedMode.eCPAP     , 'ASSERT: Invalid Vent Mode eCPAP,      ' .. mode.eCPAP     )
    assert(mode.eNCPAP     == expectedMode.eNCPAP    , 'ASSERT: Invalid Vent Mode eNCPAP,     ' .. mode.eNCPAP    )
    assert(mode.eDUOPAP    == expectedMode.eDUOPAP   , 'ASSERT: Invalid Vent Mode eDUOPAP,    ' .. mode.eDUOPAP   )
    assert(mode.eHFO       == expectedMode.eHFO      , 'ASSERT: Invalid Vent Mode eHFO,       ' .. mode.eHFO      )
    assert(mode.eO2Therapy == expectedMode.eO2Therapy, 'ASSERT: Invalid Vent Mode eO2Therapy, ' .. mode.eO2Therapy)
    assert(mode.eSERVICE   == expectedMode.eSERVICE  , 'ASSERT: Invalid Vent Mode eSERVICE,   ' .. mode.eSERVICE  )
end

function test_ModeOption1()
    local modeOpt1 = FTI.ModeOption1
    assert(modeOpt1.eStartStopBit                         ==  0, 'ASSERT: Invalid ModeOption1 eStartStopBit,                         ' .. modeOpt1.eStartStopBit                        )
    assert(modeOpt1.eStateVolumnGuaranteeBit              ==  1, 'ASSERT: Invalid ModeOption1 eStateVolumnGuaranteeBit,              ' .. modeOpt1.eStateVolumnGuaranteeBit             )
    assert(modeOpt1.eStateVolumnLimitBit                  ==  2, 'ASSERT: Invalid ModeOption1 eStateVolumnLimitBit,                  ' .. modeOpt1.eStateVolumnLimitBit                 )
    assert(modeOpt1.eVentilatorRangeBit                   ==  3, 'ASSERT: Invalid ModeOption1 eVentilatorRangeBit,                   ' .. modeOpt1.eVentilatorRangeBit                  )
    assert(modeOpt1.eFlowSensorCalibrationRunningBit      ==  4, 'ASSERT: Invalid ModeOption1 eFlowSensorCalibrationRunningBit,      ' .. modeOpt1.eFlowSensorCalibrationRunningBit     )
    assert(modeOpt1.eO2CompensationEnabledBit             ==  5, 'ASSERT: Invalid ModeOption1 eO2CompensationEnabledBit,             ' .. modeOpt1.eO2CompensationEnabledBit            )
    assert(modeOpt1.eExhalationValveCalibrationRunningBit ==  6, 'ASSERT: Invalid ModeOption1 eExhalationValveCalibrationRunningBit, ' .. modeOpt1.eExhalationValveCalibrationRunningBit)
    assert(modeOpt1.eTriggerModeBit                       ==  7, 'ASSERT: Invalid ModeOption1 eTriggerModeBit,                       ' .. modeOpt1.eTriggerModeBit                      )
    assert(modeOpt1.eCalibrationProcess_21_O2_RunningBit  ==  8, 'ASSERT: Invalid ModeOption1 eCalibrationProcess_21_O2_RunningBit,  ' .. modeOpt1.eCalibrationProcess_21_O2_RunningBit )
    assert(modeOpt1.eCalibrationProcess_100_O2_RunningBit ==  9, 'ASSERT: Invalid ModeOption1 eCalibrationProcess_100_O2_RunningBit, ' .. modeOpt1.eCalibrationProcess_100_O2_RunningBit)
    assert(modeOpt1.eTubeSet_InfantFlow_MediJetBit        == 10, 'ASSERT: Invalid ModeOption1 eTubeSet_InfantFlow_MediJetBit,        ' .. modeOpt1.eTubeSet_InfantFlow_MediJetBit       )
    assert(modeOpt1.eTubeSet_InfantFlowLPBit              == 11, 'ASSERT: Invalid ModeOption1 eTubeSet_InfantFlowLPBit,              ' .. modeOpt1.eTubeSet_InfantFlowLPBit             )
    assert(modeOpt1.eIERatioHFOBit11                      == 12, 'ASSERT: Invalid ModeOption1 eIERatioHFOBit11,                      ' .. modeOpt1.eIERatioHFOBit11                     )
    assert(modeOpt1.eIERatioHFOBit12                      == 13, 'ASSERT: Invalid ModeOption1 eIERatioHFOBit12,                      ' .. modeOpt1.eIERatioHFOBit12                     )
    assert(modeOpt1.eInternalUseBit                       == 14, 'ASSERT: Invalid ModeOption1 eInternalUseBit,                       ' .. modeOpt1.eInternalUseBit                      )
    assert(modeOpt1.eManualBreathRunningBit               == 15, 'ASSERT: Invalid ModeOption1 eManualBreathRunningBit,               ' .. modeOpt1.eManualBreathRunningBit              )
end

function test_ModeOption2()
    local modeOpt2 = FTI.ModeOption2
    assert(modeOpt2.ePressureRiseControlBit0  ==  0, 'ASSERT: Invalid ModeOption2 ePressureRiseControlBit0,  ' .. modeOpt2.ePressureRiseControlBit0 )
    assert(modeOpt2.ePressureRiseControlBit1  ==  1, 'ASSERT: Invalid ModeOption2 ePressureRiseControlBit1,  ' .. modeOpt2.ePressureRiseControlBit1 )
    assert(modeOpt2.eHFORecruitmentBit        ==  2, 'ASSERT: Invalid ModeOption2 eHFORecruitmentBit,        ' .. modeOpt2.eHFORecruitmentBit       )
    assert(modeOpt2.eHFOFlowBit               ==  3, 'ASSERT: Invalid ModeOption2 eHFOFlowBit ,              ' .. modeOpt2.eHFOFlowBit              )
    assert(modeOpt2.eReservedBit              ==  4, 'ASSERT: Invalid ModeOption2 eReservedBit,              ' .. modeOpt2.eReservedBit             )
    assert(modeOpt2.eBiasFlowBit              ==  5, 'ASSERT: Invalid ModeOption2 eBiasFlowBit,              ' .. modeOpt2.eBiasFlowBit             )
    assert(modeOpt2.eTriggerModeBit6          ==  6, 'ASSERT: Invalid ModeOption2 eTriggerModeBit6,          ' .. modeOpt2.eTriggerModeBit6         )
    assert(modeOpt2.eTriggerModeBit7          ==  7, 'ASSERT: Invalid ModeOption2 eTriggerModeBit7,          ' .. modeOpt2.eTriggerModeBit7         )
    assert(modeOpt2.eTriggerModeBit8          ==  8, 'ASSERT: Invalid ModeOption2 eTriggerModeBit8,          ' .. modeOpt2.eTriggerModeBit8         )
    assert(modeOpt2.eFOTOscillationRunningBit ==  9, 'ASSERT: Invalid ModeOption2 eFOTOscillationRunningBit, ' .. modeOpt2.eFOTOscillationRunningBit)
    assert(modeOpt2.eLeakCompensationBit10    == 10, 'ASSERT: Invalid ModeOption2 eLeakCompensationBit10,    ' .. modeOpt2.eLeakCompensationBit10   )
    assert(modeOpt2.eLeakCompensationBit11    == 11, 'ASSERT: Invalid ModeOption2 eLeakCompensationBit11,    ' .. modeOpt2.eLeakCompensationBit11   )
end
----------------------------------------------------------------------------------------
-- Call function tests
----------------------------------------------------------------------------------------
test_VentModeRange()
test_VentModes()
test_ModeOption1()
test_ModeOption2()
