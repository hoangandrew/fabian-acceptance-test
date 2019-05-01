--------------------------------------------------------------------
-- (c) Copyright 2019 Vyaire Medical, or one of its subsidiaries.
--     All Rights Reserved.
--------------------------------------------------------------------
-- Verify library
--------------------------------------------------------------------
pubFTI = require "FTI-Public-Define"

local function EXPECT_TRUE(xExpected, xMsg)
    assert(xExpected, 'ASSERT: not True' .. xMsg)
	--print(xMsg .. ' PASSED')
end

local function EXPECT_EQ(xActual, xExpected, xTolerance)    
    local absolute = 0
	local percent  = 0
	if xTolerance ~= nil then
	    absolute = xTolerance.absolute ~= nil and xTolerance.absolute or 0
		percent  = xTolerance.percent ~= nil and xTolerance.percent or 0
	end
	local tolValue = absolute + (xExpected * percent / 100)
	local minimum  = xExpected - tolValue
	local maximum  = xExpected + tolValue
	print(tolValue,xActual, minimum, maximum)
	assert(xActual >= minimum and xActual <= maximum,
	'ASSERT: not Equal' .. ' Expected: ' .. xExpected .. ' Actual: ' .. xActual)
end

local function EXPECT_NEQ(xActual, xExpected, xTolerance)    
    local absolute = 0
	local percent  = 0
	if xTolerance ~= nil then
	    absolute = xTolerance.absolute ~= nil and xTolerance.absolute or 0
		percent  = xTolerance.percent ~= nil and xTolerance.percent or 0
	end
	local tolValue = absolute + (xExpected * percent / 100)
	local minimum  = xExpected - tolValue
	local maximum  = xExpected + tolValue
	print(tolValue,xActual, minimum, maximum)
	assert(xActual < minimum or xActual > maximum,
	'ASSERT: not Equal' .. ' Expected: ' .. xExpected .. ' Actual: ' .. xActual)
end

local function EXPECT_EQ_SET(xActual, xExpected, xTolerance)
	for i = 1, #xActual do
		EXPECT_EQ(xExpected, xActual[i], xTolerance)
	end
end

verify = {
    EXPECT_EQ     = EXPECT_EQ,
	EXPECT_TRUE   = EXPECT_TRUE,
	EXPECT_EQ_SET = EXPECT_EQ_SET,
}


return verify



