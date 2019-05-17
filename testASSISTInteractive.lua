------------------------------------------------------------------------------
-- (c) Copyright 2019 Vyaire Medical, or one of its subsidiaries.
--     All Rights Reserved.
------------------------------------------------------------------------------
-- Tests fabian Terminal Interface library
------------------------------------------------------------------------------

ft      = require "fabian-Terminal"
pubFTI  = require "FTI-Public-Define"
verify  = require "verify"
utility = require "utility"

local portName = "COM6"
local on       = pubFTI.onOffState.ON
local off      = pubFTI.onOffState.OFF

local function testASSISTInteractive()
    print('INTERACTIVE: Press the artifical lung to confirm that a mechanical breath is triggered.')
	pass = utility.promptYesNoInput()
	utility.checkToContinue(pass)
end

testASSISTInteractive()