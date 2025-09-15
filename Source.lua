local Hi = loadstring(game:HttpGet("https://raw.githubusercontent.com/tungtungsahuuur/That-thing/refs/heads/main/Source.lua"))()
local console = Hi()

console:RegisterCommand("helloworld", function()
    return "helloworld"
end)

console:RegisterCommand("test", function()
    return "This is a test command!"
end)

console:RegisterCommand("clear", function()
    console:Clear()
    return "Console cleared"
end)

console:RegisterCommand("help", function()
    local commands = {}
    for cmd in pairs(console._commands) do
        table.insert(commands, cmd)
    end
    table.sort(commands)
    
    local helpText = "Available commands:\n"
    for i, cmd in ipairs(commands) do
        helpText = helpText .. "• " .. cmd .. "\n"
    end
    return helpText
end)

-- You can now specify message type when logging
console:Log("This is a normal message")
console:Log("This is an info message", "Info")
console:Log("This is a warning", "Warning")
