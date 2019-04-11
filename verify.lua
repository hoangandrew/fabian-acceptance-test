--------------------------------------------------------------------
-- (c) Copyright 2019 Vyaire Medical, or one of its subsidiaries.
--     All Rights Reserved.
--------------------------------------------------------------------
-- Verify library
--------------------------------------------------------------------

local function EXPECT_EQ(xValue, xExpected, xMsg)
    assert(xValue == xExpected, 'ASSERT: ' .. xMsg .. '. Value is ' .. tonumber(xValue) .. ', expected ' .. tonumber(xExpected))
	--print(xMsg .. ' PASSED')
end

local function EXPECT_TRUE(xExpected, xMsg)
    assert(xExpected, 'ASSERT: not True' .. xMsg)
	--print(xMsg .. ' PASSED')
end

verify = {
    EXPECT_EQ   = EXPECT_EQ,
	EXPECT_TRUE = EXPECT_TRUE
}

return verify