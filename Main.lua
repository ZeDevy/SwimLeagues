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
local clickDelay = 1
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

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

    local UISettings = SettingsTab:CollapsingHeader({ Title = "UI Settings" })

    UISettings:Keybind({
        Label = "ImGui Window Toggle",
        Value = Enum.KeyCode.Z,
        Callback = function()
            Window:SetVisible(not Window.Visible)
        end,
    })

    local AutoClaimRewards = GameTab:CollapsingHeader({ Title = "Auto Claim Rewards" })

    AutoClaimRewards:RadioButton({
        Label = "Auto Claim All Quests",
        Value = false,
        Callback = function(self, Value)
            autoClaimEnabled = Value -- Update toggle state
    
            if Value then
                task.spawn(function()
                    local Player = game.Players.LocalPlayer
                    local QuestGui = Player:WaitForChild("PlayerGui"):FindFirstChild("QuestGui")
    
                    while autoClaimEnabled do
                        task.wait(0.5)
    
                        if QuestGui then
                            local ListScrollingFrame = QuestGui.ContentFrame.ItemArea.ListArea.ListScrollingFrame
                            for _, item in pairs(ListScrollingFrame:GetChildren()) do
                                if item:IsA("Frame") then
                                    local ClaimBtn = item:FindFirstChild("ContentFrame")
                                        and item.ContentFrame:FindFirstChild("Normal")
                                        and item.ContentFrame.Normal:FindFirstChild("ButtonFrame")
                                        and item.ContentFrame.Normal.ButtonFrame:FindFirstChild("ClaimBtn")
    
                                    if ClaimBtn and ClaimBtn:IsA("ImageButton") then
                                        for _, connection in pairs(getconnections(ClaimBtn.MouseButton1Click)) do
                                            connection:Fire() -- Fire the button click
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end,
    })
    
    AutoClaimRewards:RadioButton({
        Label = "Auto Claim Daily Reward",
        Value = false,
        Callback = function(self, Value)
            autoClaimEnabled = Value -- Update toggle state
    
            if Value then
                task.spawn(function()
                    local Player = game.Players.LocalPlayer
                    local DailyRewardGui = Player:WaitForChild("PlayerGui"):FindFirstChild("DailyRewardGui")
    
                    while autoClaimEnabled do
                        task.wait(0.5)
    
                        if QuestGui then
                            local GridScrollingFrame = DailyRewardGui.ContentFrame.ItemArea.GridScrollingFrame
                            for _, item in pairs(GridScrollingFrame:GetChildren()) do
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
    

    AutoTrain:RadioButton({
        Label = "Auto Train (Blatant)",
        Value = false,
        Callback = function(self, Value)
            autoTrainEnabled = Value
    
            if Value then
                task.spawn(function()
                    while autoTrainEnabled do
                        task.wait()
    
                        game:GetService("ReplicatedStorage"):WaitForChild("Train"):WaitForChild("Remote"):WaitForChild("TrainAnimeHasEnded"):FireServer()
                    end
                end)
            end
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

    LocalPlayer:Slider({
        Label = "CFrame Speed",
        CornerRadius = UDim.new(1, 0),
        Value = Speed,
        MinValue = 1,
        MaxValue = 65,
        Callback = function(self, Value)
            Speed = Value
        end,
    })
    
    local function CFrameWalk()
        local Player = game.Players.LocalPlayer
        local HRP = Player.Character.HumanoidRootPart
        local Humanoid = Player.Character.Humanoid
        
        if Humanoid.MoveDirection.Magnitude > 0 then
            HRP.CFrame = HRP.CFrame + (Humanoid.MoveDirection * (Speed * 0.01))
        end
    end

RunService.RenderStepped:Connect(CFrameWalk)
    
    LocalPlayer:Slider({
        Label = "JumpPower",
        CornerRadius = UDim.new(1, 0),
        Value = 50,
        MinValue = 50,
        MaxValue = 80,
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
