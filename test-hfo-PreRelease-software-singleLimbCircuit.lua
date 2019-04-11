--------------------------------------------------------------------
-- (c) Copyright 2019 Vyaire Medical, or one of its subsidiaries.
--     All Rights Reserved.
--------------------------------------------------------------------
-- Tests Pre-rrelease software
--
-- Notes: 
--     1. update your portName (i.e. COM9)
--     2. Prepare HFO ventilator to accept terminal remote command
--     3. Connect patient circuit to the ventilator.
--     4. Power on the ventilator.  Let it delivery a few breaths
--     5. run command: $currentDirectory$> lua <testname>.lua 
--------------------------------------------------------------------

local fti      = require "FTI-Define"
local ft       = require "fabian-Terminal"
local verify   = require "verify"
local portName = "COM6"  
local modes    = FTI.ventMode
local range    = FTI.range

local function step_13()
    ft.setVentMode(modes.NCPAP)
    ft.setCPAP__mbar(6)	
	ft.setPManuel__mbar(12)
end

local function step_14()
    -- press and hold manual breath button
end

local function step_15()
    -- Capture pressure waveform
	-- verify the PIP = 15 +/- 2 for at least 9 seconds
end

local function test_hfo_single_limb_circuit()
    step_13()
end

--------------------------------------------------------------------
-- Call function tests
--------------------------------------------------------------------
ft.openCOM(portName)

test_hfo_single_limb_circuit()

ft.closeCOM()
