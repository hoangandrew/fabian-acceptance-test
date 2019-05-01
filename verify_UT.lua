--------------------------------------------------------------------
-- (c) Copyright 2019 Vyaire Medical, or one of its subsidiaries.
--     All Rights Reserved.
--------------------------------------------------------------------
-- Verify library Unit Test
--------------------------------------------------------------------

verify = require 'verify'

verify.EXPECT_EQ(14, 15, {absolute = 1, percent = nil})
verify.EXPECT_EQ(14, 15, {absolute = nil, percent = 30})
--verify.EXPECT_EQ(14, 15) -- expect failure

verify.EXPECT_NEQ(1, 2)
--verify.EXPECT_NEQ(1, 1)  -- expect failure
verify.EXPECT_NEQ(1, 2, {absolute = 1, percent = nil})
verify.EXPECT_NEQ(1, 2, {absolute = nil, percent = 10})