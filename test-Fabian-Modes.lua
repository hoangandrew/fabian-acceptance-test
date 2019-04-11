--------------------------------------------------------------------
-- (c) Copyright 2019 Vyaire Medical, or one of its subsidiaries.
--     All Rights Reserved.
--------------------------------------------------------------------
-- Tests fabian Terminal Interface defined in FTI-define
--
-- Notes: 
--     1. update your portName (i.e. COM9)
--     2. run command: $currentDirectory$> lua testFabianMode.lua 
--------------------------------------------------------------------

local fti      = require "FTI-Define"
local ft       = require "fabian-Terminal"
local portName = "COM9"  
local modes    = FTI.ventMode
local range    = FTI.range

local function EXPECT_EQ(xValue, xExpected, xMsg)
    assert(xValue == xExpected, 'ASSERT: ' .. xMsg .. '. Value is ' .. tonumber(xValue) .. ', expected ' .. tonumber(xExpected))
	print(xMsg .. ' PASSED')
end

-- set and verify all availalbe modes in fabian
local function test_ModeSettingAndReading()
    for k, mode in pairs(modes) do 
	    if (mode >= range.modeMIN and mode <= range.modeMAX) then
            ft.setVentMode(mode)	
	        local modeInVent = ft.getVentMode()
			local msg = 'Set mode: ' .. mode .. ', Read active mode: ' .. modeInVent
	        EXPECT_EQ(modeInVent, mode, msg)
		    ft.delay()
		end
	end
end

--------------------------------------------------------------------
-- Call function tests
--------------------------------------------------------------------
ft.openCOM(portName)
test_ModeSettingAndReading()
ft.closeCOM()
