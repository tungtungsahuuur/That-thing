local function CreateNovaTerminal()
	local HttpService = game:GetService("HttpService")
	local CoreGui = game:GetService("CoreGui")
	local MarketplaceService = game:GetService("MarketplaceService")
	local TextService = game:GetService("TextService")
	local UserInputService = game:GetService("UserInputService")

	-- Utility functions
	local function GetTimestamp()
		return os.date("%H:%M:%S")
	end

	-- NovaTerminal class
	local NovaTerminal = {}
	NovaTerminal.__index = NovaTerminal

	function NovaTerminal:Construct()
		local self = setmetatable({}, NovaTerminal)
		self:_InitializeCore()
		return self
	end

	function NovaTerminal:_InitializeCore()
		-- Fetch game information
		local gameTitle, gameId
		local success, data = pcall(function()
			local info = MarketplaceService:GetProductInfo(game.PlaceId)
			return info.Name, game.PlaceId
		end)

		if success then
			gameTitle, gameId = data, game.PlaceId
		else
			gameTitle = "Unknown Experience"
			gameId = game.PlaceId
		end

		-- Create main interface
		self._interface = Instance.new("ScreenGui")
		self._interface.Name = "NovaTerminal"
		self._interface.Parent = CoreGui
		self._interface.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		self._interface.ResetOnSpawn = false
		self._interface.DisplayOrder = 999

		-- Primary container
		self._container = Instance.new("Frame")
		self._container.Name = "TerminalFrame"
		self._container.Parent = self._interface
		self._container.BorderSizePixel = 0
		self._container.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
		self._container.AnchorPoint = Vector2.new(0.5, 0.5)
		self._container.Size = UDim2.new(0, 515, 0, 580)
		self._container.Position = UDim2.new(0.5, 0, 0.5, 0)
		self._container.BorderColor3 = Color3.fromRGB(0, 0, 0)

		-- Rounded corners
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 5)
		corner.Parent = self._container

		-- Build UI components
		self:_BuildHeader()
		self:_BuildOutputPanel()
		self:_BuildInputPanel()

		-- Message configuration
		self._messageConfig = {
			Standard = {Color = Color3.fromRGB(255, 255, 255), Tag = ""},
			Critical = {Color = Color3.fromRGB(255, 103, 106), Tag = "Error"},
			Positive = {Color = Color3.fromRGB(64, 176, 56), Tag = "Success"},
			Caution = {Color = Color3.fromRGB(176, 125, 36), Tag = "Warning"},
			Notice = {Color = Color3.fromRGB(100, 150, 255), Tag = "Info"},
			Developer = {Color = Color3.fromRGB(200, 100, 255), Tag = "Debug"}
		}

		self._messageIndex = 0
		self._commandRegistry = {}

		-- Set initial title with actual game info
		self:UpdateTitle("Nova Terminal - " .. gameTitle .. " - " .. gameId)
	end

	function NovaTerminal:_BuildHeader()
		-- Header background
		self._headerFrame = Instance.new("Frame")
		self._headerFrame.Name = "HeaderPanel"
		self._headerFrame.Parent = self._container
		self._headerFrame.BorderSizePixel = 0
		self._headerFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
		self._headerFrame.Size = UDim2.new(0, 515, 0, 50)
		self._headerFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		self._headerFrame.BackgroundTransparency = 0.9

		-- Title display
		self._titleDisplay = Instance.new("TextLabel")
		self._titleDisplay.Name = "TitleText"
		self._titleDisplay.Parent = self._headerFrame
		self._titleDisplay.TextWrapped = true
		self._titleDisplay.BorderSizePixel = 0
		self._titleDisplay.TextSize = 14
		self._titleDisplay.TextXAlignment = Enum.TextXAlignment.Left
		self._titleDisplay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		self._titleDisplay.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
		self._titleDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
		self._titleDisplay.BackgroundTransparency = 1
		self._titleDisplay.Size = UDim2.new(0, 500, 0, 24)
		self._titleDisplay.BorderColor3 = Color3.fromRGB(0, 0, 0)
		self._titleDisplay.Text = "Nova Terminal"
		self._titleDisplay.Position = UDim2.new(0.014, 0, 0.26, 0)

		-- Header separator
		self._separator = Instance.new("Frame")
		self._separator.Name = "HeaderDivider"
		self._separator.Parent = self._container
		self._separator.BorderSizePixel = 0
		self._separator.BackgroundColor3 = Color3.fromRGB(103, 103, 103)
		self._separator.Size = UDim2.new(0, 515, 0, 1)
		self._separator.Position = UDim2.new(0, 0, 0.091, 0)
		self._separator.BorderColor3 = Color3.fromRGB(0, 0, 0)
		self._separator.BackgroundTransparency = 0.85
	end

	function NovaTerminal:_BuildOutputPanel()
		-- Scrollable message area
		self._outputFrame = Instance.new("ScrollingFrame")
		self._outputFrame.Name = "MessageView"
		self._outputFrame.Parent = self._container
		self._outputFrame.Active = true
		self._outputFrame.BorderSizePixel = 0
		self._outputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		self._outputFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
		self._outputFrame.Size = UDim2.new(0, 515, 0, 497)
		self._outputFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
		self._outputFrame.Position = UDim2.new(0, 0, 0.093, 0)
		self._outputFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		self._outputFrame.ScrollBarThickness = 3
		self._outputFrame.BackgroundTransparency = 1
		self._outputFrame.CanvasPosition = Vector2.new(0, self._outputFrame.CanvasSize.Y.Offset)

		-- Layout organization
		local listLayout = Instance.new("UIListLayout")
		listLayout.Name = "MessageLayout"
		listLayout.Parent = self._outputFrame
		listLayout.Padding = UDim.new(0, 5)
		listLayout.SortOrder = Enum.SortOrder.LayoutOrder
		
		local framePadding = Instance.new("UIPadding")
		framePadding.Name = "ViewPadding"
		framePadding.Parent = self._outputFrame
		framePadding.PaddingLeft = UDim.new(0, 8)
		framePadding.PaddingTop = UDim.new(0, 5)
		framePadding.PaddingRight = UDim.new(0, 8)
		framePadding.PaddingBottom = UDim.new(0, 5)
		
		-- Auto-scroll to bottom when new content appears
		listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			self._outputFrame.CanvasPosition = Vector2.new(0, self._outputFrame.CanvasSize.Y.Offset)
		end)
	end

	function NovaTerminal:_BuildInputPanel()
		-- Input container
		local inputHolder = Instance.new("Frame")
		inputHolder.Name = "InputPanel"
		inputHolder.Parent = self._container
		inputHolder.BorderSizePixel = 0
		inputHolder.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		inputHolder.Size = UDim2.new(0, 515, 0, 40)
		inputHolder.Position = UDim2.new(0, 0, 0.93, 0)
		inputHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)

		-- Command prompt indicator
		local promptSymbol = Instance.new("TextLabel")
		promptSymbol.Name = "CommandPrompt"
		promptSymbol.Parent = inputHolder
		promptSymbol.Text = ">"
		promptSymbol.TextColor3 = Color3.fromRGB(100, 150, 255)
		promptSymbol.BackgroundTransparency = 1
		promptSymbol.Size = UDim2.new(0, 20, 1, 0)
		promptSymbol.Font = Enum.Font.Code
		promptSymbol.TextSize = 16
		promptSymbol.TextXAlignment = Enum.TextXAlignment.Center

		-- Input field container
		local inputContainer = Instance.new("Frame")
		inputContainer.Name = "InputField"
		inputContainer.Parent = inputHolder
		inputContainer.BackgroundTransparency = 1
		inputContainer.Size = UDim2.new(1, -30, 1, 0)
		inputContainer.Position = UDim2.new(0, 25, 0, 0)
		inputContainer.ClipsDescendants = true

		-- Suggestion text
		self._suggestionText = Instance.new("TextLabel")
		self._suggestionText.Name = "SuggestionHint"
		self._suggestionText.Parent = inputContainer
		self._suggestionText.Text = ""
		self._suggestionText.TextColor3 = Color3.fromRGB(120, 120, 120)
		self._suggestionText.BackgroundTransparency = 1
		self._suggestionText.Size = UDim2.new(1, 0, 1, 0)
		self._suggestionText.Font = Enum.Font.Code
		self._suggestionText.TextSize = 14
		self._suggestionText.TextXAlignment = Enum.TextXAlignment.Left
		self._suggestionText.TextYAlignment = Enum.TextYAlignment.Center
		self._suggestionText.ZIndex = 1

		-- Command input field
		self._commandField = Instance.new("TextBox")
		self._commandField.Name = "CommandEntry"
		self._commandField.Parent = inputContainer
		self._commandField.PlaceholderText = "Enter command..."
		self._commandField.Text = ""
		self._commandField.TextColor3 = Color3.fromRGB(255, 255, 255)
		self._commandField.BackgroundTransparency = 1
		self._commandField.Size = UDim2.new(1, 0, 1, 0)
		self._commandField.Font = Enum.Font.Code
		self._commandField.TextSize = 14
		self._commandField.TextXAlignment = Enum.TextXAlignment.Left
		self._commandField.TextYAlignment = Enum.TextYAlignment.Center
		self._commandField.ClearTextOnFocus = false
		self._commandField.ZIndex = 2

		-- Input divider
		local divider = Instance.new("Frame")
		divider.Name = "InputDivider"
		divider.Parent = inputHolder
		divider.BorderSizePixel = 0
		divider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		divider.Size = UDim2.new(1, 0, 0, 1)
		divider.Position = UDim2.new(0, 0, 0, 0)
		divider.BorderColor3 = Color3.fromRGB(0, 0, 0)

		-- Connect events
		self._commandField:GetPropertyChangedSignal("Text"):Connect(function()
			self:_RefreshSuggestions()
		end)

		self._commandField.FocusLost:Connect(function(enterPressed)
			if enterPressed then
				self:ProcessCommand(self._commandField.Text)
				self._commandField.Text = ""
				self._suggestionText.Text = ""
			end
		end)

		-- Custom input handling
		self._inputHandler = UserInputService.InputBegan:Connect(function(input, processed)
			if processed then return end

			if input.KeyCode == Enum.KeyCode.Tab and self._commandField:IsFocused() then
				self:_ApplySuggestion()
			end
		end)
	end

	function NovaTerminal:_RefreshSuggestions()
		local input = self._commandField.Text:lower()
		if input == "" then
			self._suggestionText.Text = ""
			self._activeSuggestion = nil
			return
		end

		-- Find matching command
		for command in pairs(self._commandRegistry) do
			if command:sub(1, #input) == input and command ~= input then
				self._suggestionText.Text = command
				self._activeSuggestion = command
				return
			end
		end

		self._suggestionText.Text = ""
		self._activeSuggestion = nil
	end

	function NovaTerminal:_ApplySuggestion()
		if self._activeSuggestion then
			self._commandField.Text = self._activeSuggestion
			self._commandField.CursorPosition = #self._activeSuggestion + 1
			self._suggestionText.Text = ""
			self._activeSuggestion = nil
		end
	end

	function NovaTerminal:_CreateMessageTemplate(textColor)
		self._messageIndex = self._messageIndex + 1

		local messageFrame = Instance.new("Frame")
		messageFrame.Name = "Message_" .. self._messageIndex
		messageFrame.BorderSizePixel = 0
		messageFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		messageFrame.Size = UDim2.new(1, -16, 0, 19)
		messageFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		messageFrame.BackgroundTransparency = 1
		messageFrame.AutomaticSize = Enum.AutomaticSize.Y
		messageFrame.LayoutOrder = self._messageIndex -- This ensures proper ordering

		local textElement = Instance.new("TextLabel")
		textElement.Name = "Content"
		textElement.TextWrapped = true
		textElement.BorderSizePixel = 0
		textElement.TextSize = 14
		textElement.TextXAlignment = Enum.TextXAlignment.Left
		textElement.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		textElement.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
		textElement.TextColor3 = textColor
		textElement.BackgroundTransparency = 1
		textElement.Size = UDim2.new(1, 0, 0, 19)
		textElement.BorderColor3 = Color3.fromRGB(0, 0, 0)
		textElement.AutomaticSize = Enum.AutomaticSize.Y
		textElement.Parent = messageFrame
		
		return messageFrame
	end

	function NovaTerminal:_DisplayMessage(messageCategory, content)
		local config = self._messageConfig[messageCategory] or self._messageConfig.Standard
		local template = self:_CreateMessageTemplate(config.Color)

		-- Format message based on type
		local formattedContent
		if messageCategory == "Standard" then
			formattedContent = string.format("[%s] %s", GetTimestamp(), content)
		else
			formattedContent = string.format("[%s] {%s} %s", GetTimestamp(), config.Tag, content)
		end

		-- Set the text content
		template:FindFirstChild("Content").Text = formattedContent
		template.Parent = self._outputFrame

		return template
	end

	function NovaTerminal:ProcessCommand(commandInput)
		if commandInput == "" then
			return
		end

		-- Log the command that was entered
		self:Record("> " .. commandInput, "Notice")

		-- Clean and process command
		local cleanCommand = commandInput:match("^%s*(.-)%s*$")
		local commandKey = cleanCommand:lower()

		-- Execute command with error handling
		local success, output = pcall(function()
			if self._commandRegistry[commandKey] then
				return self._commandRegistry[commandKey]()
			else
				error("Unrecognized command: " .. commandKey)
			end
		end)

		if success then
			if output then
				self:Record(output)
			end
		else
			self:ReportError(output)
		end
	end

	function NovaTerminal:RegisterCommand(name, action)
		local commandKey = name:lower()
		if type(action) ~= "function" then
			self:ReportError("Failed to register '" .. commandKey .. "': action must be a function")
			return false
		end

		self._commandRegistry[commandKey] = action
		return true
	end

	function NovaTerminal:Record(text, category)
		category = category or "Standard"
		return self:_DisplayMessage(category, text)
	end

	function NovaTerminal:ReportError(text)
		return self:_DisplayMessage("Critical", text)
	end

	function NovaTerminal:ConfirmSuccess(text)
		return self:_DisplayMessage("Positive", text)
	end

	function NovaTerminal:IssueWarning(text)
		return self:_DisplayMessage("Caution", text)
	end

	function NovaTerminal:PostNotice(text)
		return self:_DisplayMessage("Notice", text)
	end

	function NovaTerminal:DeveloperLog(text)
		return self:_DisplayMessage("Developer", text)
	end

	function NovaTerminal:ClearDisplay()
		for _, item in ipairs(self._outputFrame:GetChildren()) do
			if item:IsA("Frame") and item.Name:find("Message_") then
				item:Destroy()
			end
		end
		self._messageIndex = 0
	end

	function NovaTerminal:UpdateTitle(titleText)
		self._titleDisplay.Text = titleText
	end

	function NovaTerminal:ToggleView()
		self._container.Visible = not self._container.Visible
	end

	function NovaTerminal:Terminate()
		if self._inputHandler then
			self._inputHandler:Disconnect()
		end
		self._interface:Destroy()
		setmetatable(self, nil)
	end

	-- Create and return terminal instance
	local success, terminal = pcall(function()
		return NovaTerminal:Construct()
	end)

	if not success then
		local errorDisplay = Instance.new("ScreenGui")
		errorDisplay.Name = "TerminalError"
		errorDisplay.Parent = CoreGui
		errorDisplay.ResetOnSpawn = false

		local errorMessage = Instance.new("TextLabel")
		errorMessage.Text = "Terminal initialization failed: " .. tostring(terminal)
		errorMessage.Size = UDim2.new(0, 300, 0, 50)
		errorMessage.Position = UDim2.new(0.5, -150, 0, 50)
		errorMessage.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
		errorMessage.TextColor3 = Color3.fromRGB(255, 255, 255)
		errorMessage.Parent = errorDisplay

		terminal = {
			Record = function() end,
			ReportError = function() end,
			ConfirmSuccess = function() end,
			IssueWarning = function() end,
			PostNotice = function() end,
			DeveloperLog = function() end,
			ClearDisplay = function() end,
			UpdateTitle = function() end,
			ToggleView = function() end,
			Terminate = function() errorDisplay:Destroy() end,
			RegisterCommand = function() return false end,
			ProcessCommand = function() end
		}
	end

	return terminal
end

return CreateNovaTerminal
