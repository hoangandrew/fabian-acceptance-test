local function promptYesNoInput()
    local answer
    local gotValidAnswer
    repeat
       io.write(" (y/n)? ")
       io.flush()
       answer=io.read()
       gotValidAnswer = (answer == 'Y' or answer=="y" or answer == 'N' or answer=="n")
       if not(gotValidAnswer) then
          io.write("   '" .. answer .. "' is an invalid response. Please enter y or n\n")   
       end
    until gotValidAnswer
    io.write("\n") 
    io.flush()
    return answer == 'y' or answer == 'Y'
end

local function promptForContinue()
    local prompt = "Press enter to continue..." 
    local dummy
    io.write(prompt)
    io.flush()
    dummy = io.read()
end

local function checkToContinue(xPass)
    if xPass == false then
	    print("Test has FAILED") 
	    os.exit()
	end
end

utility = 
{
promptYesNoInput  = promptYesNoInput,
promptForContinue = promptForContinue,
checkToContinue   = checkToContinue,
}

return utility