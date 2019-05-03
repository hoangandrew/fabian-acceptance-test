--------------------------------------------------------------------
-- (c) Copyright 2019 Vyaire Medical, or one of its subsidiaries.
--     All Rights Reserved.
--------------------------------------------------------------------
-- Verify library
--------------------------------------------------------------------
pubFTI = require "FTI-Public-Define"
ft     = require "fabian-Terminal"

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
	print(tolValue,xActual, minimum, maximum,xTolerance.absolute)
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
	ft.printDebug(tolValue,xActual, minimum, maximum)
	assert(xActual < minimum or xActual > maximum,
	'ASSERT: not Equal' .. ' Expected: ' .. xExpected .. ' Actual: ' .. xActual)
end

local function EXPECT_LESS(xActual, xExpected, xTolerance)    
    local absolute = 0
	local percent  = 0
	if xTolerance ~= nil then
	    absolute = xTolerance.absolute ~= nil and xTolerance.absolute or 0
		percent  = xTolerance.percent ~= nil and xTolerance.percent or 0
	end
	local tolValue = absolute + (xExpected * percent / 100)
	local minimum  = xExpected - tolValue
	print(tolValue,xActual, minimum)
	assert(xActual < minimum,
	'ASSERT: not Equal' .. ' Expected: ' .. xExpected .. ' Actual: ' .. xActual)
end

local function EXPECT_GREATER(xActual, xExpected, xTolerance)    
    local absolute = 0
	local percent  = 0
	if xTolerance ~= nil then
	    absolute = xTolerance.absolute ~= nil and xTolerance.absolute or 0
		percent  = xTolerance.percent ~= nil and xTolerance.percent or 0
	end
	local tolValue = absolute + (xExpected * percent / 100)
	local maximum  = xExpected + tolValue
	print(tolValue,xActual, maximum)
	assert(xActual > maximum,
	'ASSERT: not Equal' .. ' Expected: ' .. xExpected .. ' Actual: ' .. xActual)
end

local function EXPECT_EQ_SET(xActual, xExpected, xTolerance)

        for j = 1, #xActual do
		print("expect eq SET actual = " .. xActual[j])
		 end
	for i = 1, #xActual do
		EXPECT_EQ(xActual[i], xExpected, xTolerance)
	end
end

verify = {
    EXPECT_EQ     = EXPECT_EQ,
	EXPECT_TRUE   = EXPECT_TRUE,
	EXPECT_EQ_SET = EXPECT_EQ_SET,
}


return verify



