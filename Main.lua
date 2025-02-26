local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local IsStudio = RunService:IsStudio()
local Radius = math.random(3, 10) / 10
local Speed = 1
local autoCloseEnabled = false
local autoClickEnabled = false
local autoMachineEnabled = false
local autoTrainEnabled = false
local autoClaimEnabled = false
local autoAscendEnabled = false
local autoClaimDailyEnabled = false
local clickDelay = 1
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Teleports = {}
local AutoTrain = {}
local ConsoleOutput = ""

local ImGui = loadstring(game:HttpGet("https://raw.githubusercontent.com/depthso/Roblox-ImGUI/refs/heads/main/ImGui.lua", true))()

local function CreateMainUI()
    if Window then
        Window:Close()
    end
    
    Window = ImGui:CreateWindow({
        Title = "Run.gm",
        Size = UDim2.new(0, 385, 0, 400),
    })
    Window:Center()

    local Watermark = ImGui:CreateWindow({
        Position = UDim2.fromOffset(10, 10),
        NoSelectEffect = true,
        AutoSize = "XY",
        TabsBar = false,
        NoResize = true,
        NoDrag = false,
        NoTitleBar = true,
        Border = true,
        BorderThickness = 1,
        BackgroundTransparency = 0,
    }):CreateTab({
        Visible = true
    })

    local StatsRow = Watermark:Row({
        Spacing = 10
    })

    StatsRow:Label({
        Text = "Run.gm",
        TextColor3 = Color3.fromRGB(0, 255, 255)
    })

    local MainTab = Window:CreateTab({ Name = "Main" })
    local GameTab = Window:CreateTab({ Name = "Game" })
    local SettingsTab = Window:CreateTab({ Name = "Settings" })
    local ConsoleTab = Window:CreateTab({ Name = "Console" })
    Window:ShowTab(ConsoleTab)

    local Row2 = ConsoleTab:Row()

    ConsoleTab:Separator({
        Text = "Console Example:"
    })

    local Console = ConsoleTab:Console({
        Text = ConsoleOutput,
        ReadOnly = true,
        LineNumbers = false,
        Border = false,
        Fill = true,
        Enabled = true,
        AutoScroll = true,
        RichText = true,
        MaxLines = 50
    })

    local function PrintToConsole(message)
        ConsoleOutput = ConsoleOutput .. "\n" .. message
        Console:AppendText(message)
    end
    
    -- Function to print Game ID and Job ID
    local function PrintGameInfo()
        local GameId = game.GameId
        local JobId = game.JobId
        PrintToConsole("[INFO] Game ID: " .. GameId)
        PrintToConsole("[INFO] Job ID: " .. JobId)
    end
    
    -- Print game info at startup
    PrintGameInfo()
    
    Row2:Button({
        Text = "Clear",
        Callback = function() Console:Clear() end
    })
    
    Row2:Button({
        Text = "Copy"
    })
    
    Row2:Button({
        Text = "Pause",
        Callback = function(self)
            local Paused = shared.Pause
            Paused = not (Paused or false)
            shared.Pause = Paused
            
            self.Text = Paused and "Paused" or "Pause"
            Console.Enabled = not Paused
        end,
    })
    
    Row2:Fill()

    local UISettings = SettingsTab:CollapsingHeader({ Title = "UI Settings" })

    UISettings:Keybind({
        Label = "ImGui Window Toggle",
        Value = Enum.KeyCode.Z,
        Callback = function()
            Window:SetVisible(not Window.Visible)
        end,
    })

    local AutoMachine = GameTab:CollapsingHeader({ Title = "Auto Machine" })
    local TrainMachineModelGroup = workspace:FindFirstChild("TrainMachineModelGroup")
    local Player = game.Players.LocalPlayer
    
    -- Function to Get Valid Machines (Only those with ExerciseT inside)
    local function GetMachineItems()
        local items = {}
        
        if TrainMachineModelGroup then
            for _, child in pairs(TrainMachineModelGroup:GetChildren()) do
                if child:IsA("Model") and child:FindFirstChild("ExerciseT") then
                    table.insert(items, child.Name)
                end
            end
        end
        
        return items
    end
    
    -- Function to find a valid teleport position for the machine
    local function GetMachinePosition(machine)
        if machine.PrimaryPart then
            return machine.PrimaryPart.Position
        else
            -- Find first child with a Position property
            for _, part in pairs(machine:GetChildren()) do
                if part:IsA("BasePart") then
                    return part.Position
                end
            end
        end
        return nil -- No valid part found
    end
    
    -- Function to find and trigger the proximity prompt
    local function TriggerMachinePrompt(selectedMachine)
        -- First attempt: Navigate through nested MachineInfo to find the ProximityPrompt
        local machineInfo = selectedMachine:FindFirstChild("MachineInfo")
        local nestedMachineInfo = machineInfo and machineInfo:FindFirstChild("MachineInfo")
        local attachPart = nestedMachineInfo and nestedMachineInfo:FindFirstChild("AttachUIPartAttachment")
        local proximityPrompt = attachPart and attachPart:FindFirstChildWhichIsA("ProximityPrompt")
        
        -- If not found in the expected path, search the entire machine
        if not proximityPrompt then
            local allPrompts = selectedMachine:GetDescendants()
            for _, obj in pairs(allPrompts) do
                if obj:IsA("ProximityPrompt") then
                    proximityPrompt = obj
                    break
                end
            end
        end
        
        if proximityPrompt then
            -- Use fireproximityprompt for executor
            fireproximityprompt(proximityPrompt)
            return true
        else
            warn("[ERROR] No ProximityPrompt found on selected machine!")
            return false
        end
    end
    
    -- Create the Combo Box with dynamic updating
    local ComboBox
    
    -- Function to update the combo box items
    local function UpdateComboBoxItems()
        if ComboBox then
            ComboBox:SetItems(GetMachineItems())
        end
    end
    
    ComboBox = AutoMachine:Combo({
        Placeholder = "Select Machine",
        CornerRadius = UDim.new(1, 0),
        Label = "Machines",
        Items = GetMachineItems(),
        Callback = function(self, Value)
            -- Find the selected machine
            local selectedMachine = TrainMachineModelGroup:FindFirstChild(Value)
            
            if selectedMachine then
                local character = Player.Character
                local humanoid = character and character:FindFirstChild("Humanoid")
                local HRP = character and character:FindFirstChild("HumanoidRootPart")
                local machinePosition = GetMachinePosition(selectedMachine)
                
                if humanoid and HRP and machinePosition then
                    -- Make player jump before teleporting
                    humanoid.Jump = true
                    
                    -- Wait a tiny bit for jump to start
                    task.wait(0.35)
                    
                    -- Teleport to machine
                    HRP.CFrame = CFrame.new(machinePosition + Vector3.new(0, 3, 0)) -- Teleport slightly above to prevent clipping
                    
                    -- Immediately trigger the prompt without waiting
                    TriggerMachinePrompt(selectedMachine)
                else
                    warn("[ERROR] No valid position found for the selected machine!")
                end
            else
                warn("[ERROR] Invalid machine selected! Machine not found in the list.")
            end
        end,
    })
    
    -- Set up continuous monitoring of machines
    spawn(function()
        while true do
            UpdateComboBoxItems()
            task.wait(1) -- Check every second for changes
        end
    end)
    
    -- Monitor for added/removed machines
    TrainMachineModelGroup.ChildAdded:Connect(function(child)
        task.wait(0.1) -- Brief wait to ensure ExerciseT has time to be added if applicable
        UpdateComboBoxItems()
    end)
    
    TrainMachineModelGroup.ChildRemoved:Connect(function(child)
        UpdateComboBoxItems()
    end)
    
    -- Also monitor for ExerciseT being added/removed from existing machines
    for _, machine in pairs(TrainMachineModelGroup:GetChildren()) do
        if machine:IsA("Model") then
            machine.ChildAdded:Connect(function(child)
                if child.Name == "ExerciseT" then
                    UpdateComboBoxItems()
                end
            end)
            
            machine.ChildRemoved:Connect(function(child)
                if child.Name == "ExerciseT" then
                    UpdateComboBoxItems()
                end
            end)
        end
    end
    
    local AutoClaimRewards = GameTab:CollapsingHeader({ Title = "Auto Claim Rewards" })

    AutoClaimRewards:RadioButton({
        Label = "Auto Claim All Quests",
        Value = false,
        Callback = function(self, Value)
            autoClaimEnabled = Value
    
            if Value then
                task.spawn(function()
                    -- Get references using proper protection
                    local Players = game:GetService("Players")
                    local Player = Players.LocalPlayer
                    
                    while autoClaimEnabled and task.wait(0.1) do
                        local success, error = pcall(function()
                            -- Loop through all quests and attempt to claim them
                            for _, quest in pairs(game.Players.LocalPlayer.PlayerGui.QuestGui.ContentFrame.ItemArea.ListArea.ListScrollingFrame:GetChildren()) do
                                if not autoClaimEnabled then break end
                                
                                if quest:IsA("Frame") then
                                    -- Attempt to claim the quest directly (no GUI required)
                                    local ClaimBtn = quest.ContentFrame.Normal.ButtonFrame:FindFirstChild("ClaimBtn")
                                    
                                    if ClaimBtn and ClaimBtn:IsA("ImageButton") then
                                        for _, connection in pairs(getconnections(ClaimBtn.MouseButton1Click)) do
                                            connection:Fire()
                                        end
                                    end
                                end
                            end
                        end)
                        
                        if not success then
                            Console:AppendText("[ERROR] Auto Claim Error: " .. error)
                        end
                    end
                end)
            end
        end
    })
    
    
    AutoClaimRewards:RadioButton({
        Label = "Auto Claim Daily Reward",
        Value = false,
        Callback = function(self, Value)
            local autoClaimDailyEnabled = Value
            
            if Value then
                task.spawn(function()
                    -- Get player references
                    local Players = game:GetService("Players")
                    local Player = Players.LocalPlayer
                    
                    while autoClaimDailyEnabled and task.wait(0.85) do
                        pcall(function()
                            local DailyRewardGui = Player.PlayerGui:FindFirstChild("DailyRewardGui")
                            
                            if DailyRewardGui then
                                local GridFrame = DailyRewardGui.ContentFrame.ItemArea.GridScrollingFrame
                                for _, item in ipairs(GridFrame:GetChildren()) do
                                    if not autoClaimDailyEnabled then break end
                                    
                                    if item:IsA("Frame") then
                                        local ClaimBtn = item:FindFirstChild("ContentFrame")
                                        
                                        if ClaimBtn and ClaimBtn:IsA("ImageButton") then
                                            for _, connection in pairs(getconnections(ClaimBtn.MouseButton1Click)) do
                                                connection:Fire()
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end)
            end
        end
    })

    local AutoAscend = GameTab:CollapsingHeader({ Title = "Auto Ascend" })

    AutoAscend:RadioButton({
        Label = "Auto Ascend",
        Value = false,
        Callback = function(self, Value)
            autoAscendEnabled = Value
    
            if Value then
                task.spawn(function()
                    local player = game.Players.LocalPlayer
                    local trainInfo = player.Configuration:WaitForChild("TrainValueInfo")
                    local ascendButton = player.PlayerGui.RebirthGui.Content.ContentFrame.Show.RightArea.LevelArea.AscendButton
                    local gainArea = player.PlayerGui.RebirthGui.Content.ContentFrame.Show.RightArea.GainArea
                    local machines = Workspace.TrainMachineModelGroup:GetChildren()
    
                    local muscleMap = {
                        ["Chest"] = "1",
                        ["Back"] = "2",
                        ["Abdomen"] = "3",
                        ["Legs"] = "4",
                        ["Arms"] = "5"
                    }
    
                    local machineMap = {
                        ["1"] = "PectoralesInstrument_1", -- Chest
                        ["2"] = "BackInstrument_1",      -- Back
                        ["3"] = "AbdominalInstrument_1", -- Abs
                        ["4"] = "LegInstrument_1",      -- Legs
                        ["5"] = "ArmInstrument_1"       -- Arms
                    }
    
                    while autoAscendEnabled do
                        task.wait(0.1) -- Small delay to prevent lag
    
                        local canAscend = false
    
                        for muscle, attrIndex in pairs(muscleMap) do
                            local muscleValue = trainInfo:GetAttribute(attrIndex) or 0
                            local numText = gainArea:FindFirstChild(muscle) and gainArea[muscle].Bar.NumText.Text
    
                            if numText then
                                local current, required = numText:match("(%d+)/(%d+)")
                                current, required = tonumber(current), tonumber(required)
    
                                if current and required and muscleValue >= required then
                                    canAscend = true
                                    break
                                end
                            end
                        end
    
                        if canAscend then
                            -- Trigger MouseButton1Click for ascendButton using the same logic as your example
                            if ascendButton and ascendButton:IsA("ImageButton") then
                                for _, connection in pairs(getconnections(ascendButton.MouseButton1Click)) do
                                    connection:Fire()
                                end
                            end
                        else
                            for muscle, attrIndex in pairs(muscleMap) do
                                for _, machine in ipairs(machines) do
                                    if machine.Name == machineMap[attrIndex] and machine:FindFirstChild("ExerciseT") then
                                        local prompt = machine.MachineInfo.MachineInfo.AttachUIPartAttachment.ProximityPrompt
                                        if prompt then
                                            fireproximityprompt(prompt)
                                        end
                                        break
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end,
    })
    
    local AutoTrain = GameTab:CollapsingHeader({ Title = "Auto Train" })

    AutoTrain:Label({
        Text = [[<b>Turn on Auto Train on the Machine your using before Turnning on the Auto Train Legit. This is only for Auto Train (Legit)</b>]],
        RichText = true,
        TextWrapped = true,
    })

    local Legit = AutoTrain:RadioButton({
        Label = "Auto Train (Legit)",
        Value = false,
        Callback = function(self, Value)
            autoMachineEnabled = Value
    
            if Value then
                task.spawn(function()
                    local Player = game.Players.LocalPlayer
                    local MachineUseGui = Player:WaitForChild("PlayerGui"):FindFirstChild("MachineUseGui")
    
                    while autoMachineEnabled do
                        task.wait(0.01)
    
                        if MachineUseGui and MachineUseGui.Enabled then
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                            task.wait(clickDelay)
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                        end
                    end
                end)
            end
        end,
    })

    AutoTrain:Keybind({
        Label = "Auto Train Toggle (Legit)",
        Value = Enum.KeyCode.X,
        Callback = function()
            Legit:Toggle()
        end,
    })

    AutoTrain:Slider({
        Label = "Auto Click Delay (Legit)",
        CornerRadius = UDim.new(1, 0),
        Value = clickDelay,
        MinValue = 0.0,
        MaxValue = 5,
        Callback = function(self, Value)
            clickDelay = Value
        end,
    })

    local function setupAutoTrain()
        game:GetService("ReplicatedStorage"):WaitForChild("Train"):WaitForChild("Remote"):WaitForChild("TrainAnimeHasEnded"):FireServer()
    end
    
     AutoTrain:RadioButton({
        Label = "Auto Train (Blatant)",
        Value = false,
        Callback = function(self, Value)
            autoTrainEnabled = Value
            if Value then
                task.spawn(function()
                    while autoTrainEnabled do
                        task.wait()
                        setupAutoTrain()
                    end
                end)
            end
        end,
    })

    local function autoTrainLegit()
        local Player = game.Players.LocalPlayer
        local MachineUseGui = Player:WaitForChild("PlayerGui"):FindFirstChild("MachineUseGui")
        local clickDelay = 0.01  -- Adjust for speed
    
        while autoMachineEnabled do
            task.wait(0.01)
    
            if MachineUseGui and MachineUseGui.Enabled then
                -- Simulate a mouse click
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(clickDelay)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end
        end
    end
    
    -- Function to simulate firing remote for Blatant Mode
    local function autoTrainBlatant()
        while autoTrainEnabled do
            task.wait()
            game:GetService("ReplicatedStorage"):WaitForChild("Train"):WaitForChild("Remote"):WaitForChild("TrainAnimeHasEnded"):FireServer()
        end
    end
    
    -- Combine both AutoTrain modes
    local ATV2 = AutoTrain:RadioButton({
        Label = "Auto Train (Legit & Blatant)",
        Value = false,
        Callback = function(self, Value)
            autoMachineEnabled = Value
            autoTrainEnabled = Value
    
            if Value then
                -- Hide the window and lock mouse
                Window:SetVisible(false)
                game:GetService("UserInputService").MouseBehavior = Enum.MouseBehavior.LockCenter
                game:GetService("UserInputService").MouseIconEnabled = false
    
                -- Start both auto modes concurrently
                task.spawn(autoTrainLegit)
                task.spawn(autoTrainBlatant)
            else
                -- Unlock mouse and show window when turned off
                Window:SetVisible(true)
                game:GetService("UserInputService").MouseBehavior = Enum.MouseBehavior.Default
                game:GetService("UserInputService").MouseIconEnabled = true
            end
        end,
    })

    AutoTrain:Keybind({
        Label = "Auto Train (Legit & Blatant)",
        Value = Enum.KeyCode.V,
        Callback = function()
            ATV2:Toggle()
        end,
    })


    local Racing = GameTab:CollapsingHeader({ Title = "Racing" })

    Racing:RadioButton({
        Label = "Auto Close Race Results",
        Value = false,
        Callback = function(self, Value)
            autoCloseEnabled = Value
    
            if Value then
                task.spawn(function()
                    while autoCloseEnabled do
                        task.wait(0.1)
    
                        local Player = game.Players.LocalPlayer
                        local MatchResultGui = Player:WaitForChild("PlayerGui"):FindFirstChild("MatchResultGui")
    
                        if MatchResultGui and MatchResultGui.Enabled then
                            local CloseButton = MatchResultGui:FindFirstChild("ContentFrame")
                                and MatchResultGui.ContentFrame:FindFirstChild("CloseButton")
    
                            if CloseButton and CloseButton:IsA("ImageButton") then
                                for _, connection in pairs(getconnections(CloseButton.MouseButton1Click)) do
                                    connection:Fire()
                                end
                            end
                        end
                    end
                end)
            end
        end,
    })

    Racing:Slider({
        Label = "Auto Click Delay",
        CornerRadius = UDim.new(1, 0),
        Value = clickDelay, -- Initial value set to 0.05
        MinValue = 0.0,
        MaxValue = 5,
        Callback = function(self, Value)
            clickDelay = Value
        end,
    })
    
    Racing:RadioButton({
        Label = "Auto Click (Only For Race)",
        Value = false,
        Callback = function(self, Value)
            autoClickEnabled = Value -- Update state
    
            if Value then
                task.spawn(function()
                    local Player = game.Players.LocalPlayer
                    local MatchGui = Player:WaitForChild("PlayerGui"):FindFirstChild("MatchGui")
    
                    while autoClickEnabled do
                        task.wait(0.01) -- Small delay to prevent excessive CPU usage
    
                        if MatchGui and MatchGui.Enabled then
                            -- Simulate a left mouse click
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                            task.wait(clickDelay) -- Delay between clicks (updated by the slider)
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                        end
                    end
                end)
            end
        end,
    })

    local LocalPlayer = MainTab:CollapsingHeader({ Title = "Character" })


    local function CFrameWalk()
        local Player = game.Players.LocalPlayer
        if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") or not Player.Character:FindFirstChild("Humanoid") then
            return
        end
    
        local HRP = Player.Character.HumanoidRootPart
        local Humanoid = Player.Character.Humanoid
    
        local speedValue = tonumber(Speed) or 0
    
        if Humanoid.MoveDirection.Magnitude > 0 then
            HRP.CFrame = HRP.CFrame + (Humanoid.MoveDirection * (speedValue * 0.01))
        end
    end
    
    RunService.RenderStepped:Connect(CFrameWalk)
    

    LocalPlayer:InputText({
        Label = "CFrame Speed",
        PlaceHolder = "CFrame Speed",
        CornerRadius = UDim.new(1, 0),
        Value = Speed,
        Callback = function(self, Value)
            Speed = Value
        end,
    })

    LocalPlayer:InputText({
        Label = "JumpPower",
        PlaceHolder = "JumpPower",
        CornerRadius = UDim.new(1, 0),
        Value = 50,
        Callback = function(self, Value)
            local Player = game.Players.LocalPlayer
            if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
                Player.Character.Humanoid.UseJumpPower = true
                Player.Character.Humanoid.JumpPower = Value
            end
        end,
    })
end

local KeySystem = ImGui:CreateWindow({
    Title = "Run.gm",
    TabsBar = false,
    AutoSize = "Y",
    NoCollapse = true,
    NoResize = false,
    NoClose = true
})
KeySystem:Center()

local Content = KeySystem:CreateTab({ Visible = true })
local Key = Content:InputText({
    Label = "Want Key? Just Click Enter!",
    PlaceHolder = "Enter key here",
    Value = "",
})

Content:Button({
    Text = "Enter",
    Callback = function()
        if Key:GetValue() == "" then
            KeySystem:Close()
            CreateMainUI()
        else
            Console:AppendText("<font color='rgb(240, 40, 10)'>Invalid key entered!</font>")
        end
    end
})
