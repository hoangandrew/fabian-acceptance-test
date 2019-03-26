------------------------------------------------------------------------------
-- (c) Copyright 2019 Vyaire Medical, or one of its subsidiaries.
--     All Rights Reserved.
------------------------------------------------------------------------------
fti = require "FTI-define"

----------------------------------------------------------------------------------------
-- Tests fabian Terminal Interface defined in FTI-define
----------------------------------------------------------------------------------------

function verify_VentModeRange()
    local minMode = 1
	local maxMode = 10
    
	local isValidMode = (minMode >= FTI.ventMode.eIPPV) and (maxMode <= FTI.ventMode.eO2Therapy)
    assert(isValidMode, 'ASSERT: Vent Mode Out-of-range')
	
	local isServiceMode = FTI.ventMode.eSERVICE == 15
	assert(isServiceMode, 'ASSERT: Invalid Service Mode')
end

function verify_VentModes()
    verify_VentModeRange()
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
	assert(expectedMode.eNONE      == FTI.ventMode.eNONE     , 'ASSERT: Invalid Vent Mode eNONE     , ' .. FTI.ventMode.eNONE     )
	assert(expectedMode.eIPPV      == FTI.ventMode.eIPPV     , 'ASSERT: Invalid Vent Mode eIPPV     , ' .. FTI.ventMode.eIPPV     )
	assert(expectedMode.eSIPPV     == FTI.ventMode.eSIPPV    , 'ASSERT: Invalid Vent Mode eSIPPV    , ' .. FTI.ventMode.eSIPPV    )
	assert(expectedMode.eSIMV      == FTI.ventMode.eSIMV     , 'ASSERT: Invalid Vent Mode eSIMV     , ' .. FTI.ventMode.eSIMV     )
	assert(expectedMode.eSIMVPSV   == FTI.ventMode.eSIMVPSV  , 'ASSERT: Invalid Vent Mode eSIMVPSV  , ' .. FTI.ventMode.eSIMVPSV  )
	assert(expectedMode.ePSV       == FTI.ventMode.ePSV      , 'ASSERT: Invalid Vent Mode ePSV      , ' .. FTI.ventMode.ePSV      )
	assert(expectedMode.eCPAP      == FTI.ventMode.eCPAP     , 'ASSERT: Invalid Vent Mode eCPAP     , ' .. FTI.ventMode.eCPAP     )
	assert(expectedMode.eNCPAP     == FTI.ventMode.eNCPAP    , 'ASSERT: Invalid Vent Mode eNCPAP    , ' .. FTI.ventMode.eNCPAP    )
	assert(expectedMode.eDUOPAP    == FTI.ventMode.eDUOPAP   , 'ASSERT: Invalid Vent Mode eDUOPAP   , ' .. FTI.ventMode.eDUOPAP   )
	assert(expectedMode.eHFO       == FTI.ventMode.eHFO      , 'ASSERT: Invalid Vent Mode eHFO      , ' .. FTI.ventMode.eHFO      )
	assert(expectedMode.eO2Therapy == FTI.ventMode.eO2Therapy, 'ASSERT: Invalid Vent Mode eO2Therapy, ' .. FTI.ventMode.eO2Therapy)
	assert(expectedMode.eSERVICE   == FTI.ventMode.eSERVICE  , 'ASSERT: Invalid Vent Mode eSERVICE  , ' .. FTI.ventMode.eSERVICE  )
end

----------------------------------------------------------------------------------------
-- Call function tests
----------------------------------------------------------------------------------------
verify_VentModeRange()
verify_VentModes()


