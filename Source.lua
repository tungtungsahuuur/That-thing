local function LoadAdvancedConsole()
	local HttpService = game:GetService("HttpService")
	local CoreGui = game:GetService("CoreGui")
	local MarketplaceService = game:GetService("MarketplaceService")
	local TextService = game:GetService("TextService")
	local UserInputService = game:GetService("UserInputService")

	-- Get formatted timestamp
	local function getTimestamp()
		return os.date("%H:%M:%S")
	end

	-- Console class implementation
	local AdvancedConsole = {}
	AdvancedConsole.__index = AdvancedConsole

	function AdvancedConsole.new()
		local self = setmetatable({}, AdvancedConsole)
		self:_initialize()
		return self
	end

	function AdvancedConsole:_initialize()
		-- Get game info with error handling
		local gameName, placeId
		local success, result = pcall(function()
			local gameInfo = MarketplaceService:GetProductInfo(game.PlaceId)
			return gameInfo.Name, game.PlaceId
		end)

		if success then
			gameName, placeId = result, game.PlaceId
		else
			gameName = "Unknown Game"
			placeId = game.PlaceId
		end

		-- Create main container
		self._screenGui = Instance.new("ScreenGui")
		self._screenGui.Name = "AdvancedConsole"
		self._screenGui.Parent = CoreGui
		self._screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		self._screenGui.ResetOnSpawn = false
		self._screenGui.DisplayOrder = 999

		-- Create main frame
		self._mainFrame = Instance.new("Frame")
		self._mainFrame.Name = "MainFrame"
		self._mainFrame.Parent = self._screenGui
		self._mainFrame.BorderSizePixel = 0
		self._mainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
		self._mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		self._mainFrame.Size = UDim2.new(0, 515, 0, 580)
		self._mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
		self._mainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)

		-- Add rounded corners
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0, 5)
		uiCorner.Parent = self._mainFrame

		-- Create UI components
		self:_createHeader()
		self:_createMessageContainer()
		self:_createCommandBox()

		-- Message type configurations
		self._messageTypes = {
				Normal = {Color = Color3.fromRGB(255, 255, 255), Prefix = ""},
				Error = {Color = Color3.fromRGB(255, 103, 106), Prefix = "Error"},
				Success = {Color = Color3.fromRGB(64, 176, 56), Prefix = "Success"},
				Warning = {Color = Color3.fromRGB(176, 125, 36), Prefix = "Warning"},
				Info = {Color = Color3.fromRGB(100, 150, 255), Prefix = "Info"},
				Debug = {Color = Color3.fromRGB(200, 100, 255), Prefix = "Debug"}
				}

				self._messageCount = 0

				-- Empty command registry - commands will be added externally
				self._commands = {}

				-- Set initial title with actual game info
				self:SetTitle("Console - " .. gameName .. " - " .. placeId)

				-- Removed initialization messages as requested
	end

	function AdvancedConsole:_createHeader()
		-- Header background
		self._header = Instance.new("Frame")
		self._header.Name = "Header"
		self._header.Parent = self._mainFrame
		self._header.BorderSizePixel = 0
		self._header.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
		self._header.Size = UDim2.new(0, 515, 0, 50)
		self._header.BorderColor3 = Color3.fromRGB(0, 0, 0)
		self._header.BackgroundTransparency = 0.9

		-- Title label
		self._titleLabel = Instance.new("TextLabel")
		self._titleLabel.Name = "Title"
		self._titleLabel.Parent = self._header
		self._titleLabel.TextWrapped = true
		self._titleLabel.BorderSizePixel = 0
		self._titleLabel.TextSize = 14
		self._titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		self._titleLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		self._titleLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
		self._titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		self._titleLabel.BackgroundTransparency = 1
		self._titleLabel.Size = UDim2.new(0, 500, 0, 24)
		self._titleLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
		self._titleLabel.Text = "Advanced Console"
		self._titleLabel.Position = UDim2.new(0.014, 0, 0.26, 0)

				-- Header divider
				self._divider = Instance.new("Frame")
				self._divider.Name = "Divider"
				self._divider.Parent = self._mainFrame
				self._divider.BorderSizePixel = 0
				self._divider.BackgroundColor3 = Color3.fromRGB(103, 103, 103)
				self._divider.Size = UDim2.new(0, 515, 0, 1)
				self._divider.Position = UDim2.new(0, 0, 0.091, 0)
				self._divider.BorderColor3 = Color3.fromRGB(0, 0, 0)
				self._divider.BackgroundTransparency = 0.85
	end

	function AdvancedConsole:_createMessageContainer()
		-- Scrolling frame for messages
		self._messageContainer = Instance.new("ScrollingFrame")
		self._messageContainer.Name = "MessageContainer"
		self._messageContainer.Parent = self._mainFrame
		self._messageContainer.Active = true
		self._messageContainer.BorderSizePixel = 0
		self._messageContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		self._messageContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
		self._messageContainer.Size = UDim2.new(0, 515, 0, 497)
		self._messageContainer.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
		self._messageContainer.Position = UDim2.new(0, 0, 0.093, 0)
		self._messageContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
		self._messageContainer.ScrollBarThickness = 3
		self._messageContainer.BackgroundTransparency = 1

		-- Layout and padding
		local uiListLayout = Instance.new("UIListLayout")
		uiListLayout.Name = "ListLayout"
		uiListLayout.Parent = self._messageContainer
		uiListLayout.Padding = UDim.new(0, 5)
		local uiPadding = Instance.new("UIPadding")
		uiPadding.Name = "Padding"
		uiPadding.Parent = self._messageContainer
		uiPadding.PaddingLeft = UDim.new(0, 8)
		uiPadding.PaddingTop = UDim.new(0, 5)
		uiPadding.PaddingRight = UDim.new(0, 8)
		uiPadding.PaddingBottom = UDim.new(0, 5)
	end

	function AdvancedConsole:_createCommandBox()
		-- Command box container
		local commandContainer = Instance.new("Frame")
		commandContainer.Name = "CommandContainer"
		commandContainer.Parent = self._mainFrame
		commandContainer.BorderSizePixel = 0
		commandContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		commandContainer.Size = UDim2.new(0, 515, 0, 40)
		commandContainer.Position = UDim2.new(0, 0, 0.93, 0)
		commandContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)

			-- Command prompt symbol
			local prompt = Instance.new("TextLabel")
			prompt.Name = "Prompt"
			prompt.Parent = commandContainer
			prompt.Text = ">"
			prompt.TextColor3 = Color3.fromRGB(100, 150, 255)
			prompt.BackgroundTransparency = 1
			prompt.Size = UDim2.new(0, 20, 1, 0)
			prompt.Font = Enum.Font.Code
			prompt.TextSize = 16
			prompt.TextXAlignment = Enum.TextXAlignment.Center

			-- Command input container
			local inputContainer = Instance.new("Frame")
			inputContainer.Name = "InputContainer"
			inputContainer.Parent = commandContainer
			inputContainer.BackgroundTransparency = 1
			inputContainer.Size = UDim2.new(1, -30, 1, 0)
			inputContainer.Position = UDim2.new(0, 25, 0, 0)
			inputContainer.ClipsDescendants = true

			-- Ghost text for suggestions
			self._ghostText = Instance.new("TextLabel")
			self._ghostText.Name = "GhostText"
			self._ghostText.Parent = inputContainer
			self._ghostText.Text = ""
			self._ghostText.TextColor3 = Color3.fromRGB(120, 120, 120)
			self._ghostText.BackgroundTransparency = 1
			self._ghostText.Size = UDim2.new(1, 0, 1, 0)
			self._ghostText.Font = Enum.Font.Code
			self._ghostText.TextSize = 14
			self._ghostText.TextXAlignment = Enum.TextXAlignment.Left
			self._ghostText.TextYAlignment = Enum.TextYAlignment.Center
			self._ghostText.ZIndex = 1

			-- Command input textbox
			self._commandInput = Instance.new("TextBox")
			self._commandInput.Name = "CommandInput"
			self._commandInput.Parent = inputContainer
			self._commandInput.PlaceholderText = "Type commands here..."
			self._commandInput.Text = ""
			self._commandInput.TextColor3 = Color3.fromRGB(255, 255, 255)
			self._commandInput.BackgroundTransparency = 1
			self._commandInput.Size = UDim2.new(1, 0, 1, 0)
			self._commandInput.Font = Enum.Font.Code
			self._commandInput.TextSize = 14
			self._commandInput.TextXAlignment = Enum.TextXAlignment.Left
			self._commandInput.TextYAlignment = Enum.TextYAlignment.Center
			self._commandInput.ClearTextOnFocus = false
			self._commandInput.ZIndex = 2

			-- Command box divider
			local divider = Instance.new("Frame")
			divider.Name = "CommandDivider"
			divider.Parent = commandContainer
			divider.BorderSizePixel = 0
			divider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
			divider.Size = UDim2.new(1, 0, 0, 1)
			divider.Position = UDim2.new(0, 0, 0, 0)
			divider.BorderColor3 = Color3.fromRGB(0, 0, 0)

				-- Connect events
				self._commandInput:GetPropertyChangedSignal("Text"):Connect(function()
					self:_updateSuggestion()
				end)

				self._commandInput.FocusLost:Connect(function(enterPressed)
					if enterPressed then
							self:ExecuteCommand(self._commandInput.Text)
							self._commandInput.Text = ""
							self._ghostText.Text = ""
					end
				end)

				-- Custom input handling to prevent Tab from inserting spaces
				self._inputConnection = UserInputService.InputBegan:Connect(function(input, processed)
					if processed then return end

					if input.KeyCode == Enum.KeyCode.Tab and self._commandInput:IsFocused() then
						-- Prevent default Tab behavior (inserting spaces)
						self:_completeSuggestion()
					end
				end)
	end

	function AdvancedConsole:_updateSuggestion()
		local text = self._commandInput.Text:lower()
		if text == "" then
			self._ghostText.Text = ""
			self._currentSuggestion = nil
			return
		end

		-- Find matching command
		for commandName in pairs(self._commands) do
			if commandName:sub(1, #text) == text and commandName ~= text then
				self._ghostText.Text = commandName
				self._currentSuggestion = commandName
				return
			end
		end

		self._ghostText.Text = ""
		self._currentSuggestion = nil
	end

	function AdvancedConsole:_completeSuggestion()
		if self._currentSuggestion then
			self._commandInput.Text = self._currentSuggestion
			-- Move cursor to end of text
			self._commandInput.CursorPosition = #self._currentSuggestion + 1
			self._ghostText.Text = ""
			self._currentSuggestion = nil
		end
	end

	function AdvancedConsole:_createMessageTemplate(textColor)
		self._messageCount = self._messageCount + 1

		local template = Instance.new("Frame")
		template.Name = "Message_" .. self._messageCount
		template.BorderSizePixel = 0
		template.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		template.Size = UDim2.new(1, -16, 0, 19)
		template.BorderColor3 = Color3.fromRGB(0, 0, 0)
		template.BackgroundTransparency = 1
		template.AutomaticSize = Enum.AutomaticSize.Y

		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "Text"
		textLabel.TextWrapped = true
		textLabel.BorderSizePixel = 0
		textLabel.TextSize = 14
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		textLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
		textLabel.TextColor3 = textColor
		textLabel.BackgroundTransparency = 1
		textLabel.Size = UDim2.new(1, 0, 0, 19)
		textLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
		textLabel.AutomaticSize = Enum.AutomaticSize.Y
		textLabel.Parent = template
			return template
	end

	function AdvancedConsole:_addMessage(messageType, text)
		local config = self._messageTypes[messageType] or self._messageTypes.Normal
		local template = self:_createMessageTemplate(config.Color)

		-- Format message based on type
		local formattedText
		if messageType == "Normal" then
			formattedText = string.format("[%s] %s", getTimestamp(), text)
		else
			formattedText = string.format("[%s] {%s} %s", getTimestamp(), config.Prefix, text)
		end

		-- Find the text label and set its text
		template:FindFirstChild("Text").Text = formattedText
		template.Parent = self._messageContainer

		return template
	end

	function AdvancedConsole:ExecuteCommand(commandText)
		if commandText == "" then
			return
		end

		-- Log the command that was entered
		self:Log("> " .. commandText)

		-- Trim and get command
		local trimmedCommand = commandText:match("^%s*(.-)%s*$")
		local commandName = trimmedCommand:lower()

		-- Execute command with error handling
		local success, result = pcall(function()
			if self._commands[commandName] then
				return self._commands[commandName]()
			else
				error("Unknown command: " .. commandName)
			end
		end)

		if success then
			if result then
				self:Log(result)
			end
		else
			-- Handle error internally using console:Error
			self:Error(result)
		end
	end

	function AdvancedConsole:RegisterCommand(name, callback)
		local commandName = name:lower()
		if type(callback) ~= "function" then
			self:Error("Cannot register command '" .. commandName .. "': callback must be a function")
			return false
		end

		self._commands[commandName] = callback
		-- Removed success notification as requested
		return true
	end

	function AdvancedConsole:Log(text)
		return self:_addMessage("Normal", text)
	end

	function AdvancedConsole:Error(text)
		return self:_addMessage("Error", text)
	end

	function AdvancedConsole:Success(text)
		return self:_addMessage("Success", text)
	end

	function AdvancedConsole:Warn(text)
		return self:_addMessage("Warning", text)
	end

	function AdvancedConsole:Info(text)
		return self:_addMessage("Info", text)
	end

	function AdvancedConsole:Debug(text)
		return self:_addMessage("Debug", text)
	end

	function AdvancedConsole:Clear()
		for _, child in ipairs(self._messageContainer:GetChildren()) do
			if child:IsA("Frame") and child.Name:find("Message_") then
				child:Destroy()
			end
		end
		self._messageCount = 0
		-- Removed success notification
	end

	function AdvancedConsole:SetTitle(title)
		self._titleLabel.Text = title
		-- Removed info notification
	end

	function AdvancedConsole:ToggleVisibility()
		self._mainFrame.Visible = not self._mainFrame.Visible
		-- Removed info notification
	end

	function AdvancedConsole:Destroy()
		if self._inputConnection then
			self._inputConnection:Disconnect()
		end
		self._screenGui:Destroy()
		setmetatable(self, nil)
	end

	-- Create and return console instance
	local success, console = pcall(function()
		return AdvancedConsole.new()
	end)

	if not success then
		local errorScreen = Instance.new("ScreenGui")
		errorScreen.Name = "ConsoleError"
		errorScreen.Parent = CoreGui
		errorScreen.ResetOnSpawn = false

		local errorLabel = Instance.new("TextLabel")
		errorLabel.Text = "Console initialization failed: " .. tostring(console)
		errorLabel.Size = UDim2.new(0, 300, 0, 50)
		errorLabel.Position = UDim2.new(0.5, -150, 0, 50)
		errorLabel.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
		errorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		errorLabel.Parent = errorScreen

		console = {
			Log = function() end,
			Error = function() end,
			Success = function() end,
			Warn = function() end,
			Info = function() end,
			Debug = function() end,
			Clear = function() end,
			SetTitle = function() end,
			ToggleVisibility = function() end,
			Destroy = function() errorScreen:Destroy() end,
			RegisterCommand = function() return false end,
			ExecuteCommand = function() end
		}
	end

	return console
end

return LoadAdvancedConsole
