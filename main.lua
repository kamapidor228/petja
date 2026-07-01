
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "pena goev hub",
   LoadingTitle = "loading ратки",
   LoadingSubtitle = "by навальный",
   ConfigurationSaving = { Enabled = false },
   Theme = "AmberGlow" 
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera


_G.Aimbot = false
_G.AimbotSmooth = 1 
_G.TargetLockEnabled = false 
_G.WallCheck = true
_G.HitboxEnabled = false
_G.HitboxSize = 40
_G.Chams = false
_G.Tracers = false
_G.Names = false
_G.TracerOrigin = "Bottom"
_G.AimbotFOV = 100 
_G.TargetPart = "Head"


_G.TargetESPColor = Color3.fromRGB(255, 255, 255)
_G.TargetESPThickness = 2
_G.TargetESPSize = 15 
_G.TargetESPGap = 20 
_G.TargetESPSpeed = 150
_G.TargetESPOrigin = "Target Part" 
local CurrentAngle = 0

_G.FlyEnabled = false
_G.FlySpeed = 50
_G.Noclip = false
_G.FastStrafe = false
_G.StrafeSpeed = 50
_G.WalkSpeed = 16
_G.JumpPower = 50
_G.LandEffect = true
_G.WaveStyle = "Filled" 
_G.CameraFOV = 70 
_G.GlobalThemeColor = Color3.fromRGB(100, 120, 140) 

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Visible = false


local IndicatorLines = {}
for i = 1, 8 do
    IndicatorLines[i] = Drawing.new("Line")
    IndicatorLines[i].Thickness = _G.TargetESPThickness
    IndicatorLines[i].Color = _G.TargetESPColor
    IndicatorLines[i].Visible = false
end

local PlayerTracers = {}
local PlayerNames = {}
local CurrentLockedTarget = nil 

local IsRMBDown = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        IsRMBDown = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        IsRMBDown = false
    end
end)


local function GetClosestPlayer()
    if _G.TargetLockEnabled and CurrentLockedTarget then
        if CurrentLockedTarget.Parent and CurrentLockedTarget:FindFirstChild(_G.TargetPart) then
            return CurrentLockedTarget[_G.TargetPart], CurrentLockedTarget
        else
            CurrentLockedTarget = nil
            _G.TargetLockEnabled = false
            Rayfield:Notify({Title = "Combat", Content = "Зафиксированная цель потеряна!", Duration = 2})
        end
    end

    local targetPart, targetChar = nil, nil
    local dist = _G.AimbotFOV

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(_G.TargetPart) then
            local part = p.Character[_G.TargetPart]
            local pos, os = Camera:WorldToViewportPoint(part.Position)
            if os and pos.Z > 0 then
                local mag = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                if mag < dist then
                    dist = mag
                    targetPart = part
                    targetChar = p.Character
                end
            end
        end
    end
    return targetPart, targetChar
end


local function ToggleFly(Value)
    _G.FlyEnabled = Value
    Rayfield:Notify({
        Title = "Movement",
        Content = "Fly: " .. (Value and "ON" or "OFF"),
        Duration = 2
    })

    local char = LocalPlayer.Character
    if Value and char and char:FindFirstChild("HumanoidRootPart") then
        local bv = char.HumanoidRootPart:FindFirstChild("FlyVelocity") or Instance.new("BodyVelocity")
        bv.Name = "FlyVelocity"
        bv.Parent = char.HumanoidRootPart
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0,0,0)
        
        local bg = char.HumanoidRootPart:FindFirstChild("FlyGyro") or Instance.new("BodyGyro")
        bg.Name = "FlyGyro"
        bg.Parent = char.HumanoidRootPart
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.P = 9000
        bg.CFrame = char.HumanoidRootPart.CFrame
    else
        if char and char:FindFirstChild("HumanoidRootPart") then
           if char.HumanoidRootPart:FindFirstChild("FlyVelocity") then char.HumanoidRootPart.FlyVelocity:Destroy() end
           if char.HumanoidRootPart:FindFirstChild("FlyGyro") then char.HumanoidRootPart.FlyGyro:Destroy() end
        end
    end
end


local MainTab = Window:CreateTab("Combat", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local MoveTab = Window:CreateTab("Movement", 4483362458)


MainTab:CreateToggle({
   Name = "Enable Aimbot",
   CurrentValue = false,
   Callback = function(Value) _G.Aimbot = Value; FOVCircle.Visible = Value end,
})

MainTab:CreateSlider({
   Name = "Aimbot FOV Radius",
   Range = {10, 600},
   Increment = 5,
   CurrentValue = 100,
   Callback = function(Value) _G.AimbotFOV = Value end,
})

MainTab:CreateSlider({
   Name = "Aimbot Smoothness",
   Range = {1, 20},
   Increment = 1,
   CurrentValue = 1,
   Callback = function(Value) _G.AimbotSmooth = Value end,
})

MainTab:CreateKeybind({
   Name = "Aimbot Target Lock",
   CurrentKeybind = "T",
   HoldToInteract = false,
   FileFolder = "NurikaHubSettings",
   Callback = function(Key)
      if _G.TargetLockEnabled then
         _G.TargetLockEnabled = false
         CurrentLockedTarget = nil
         Rayfield:Notify({Title = "Combat", Content = "Фиксация снята!", Duration = 2})
      else
         local _, char = GetClosestPlayer()
         if char then
            CurrentLockedTarget = char
            _G.TargetLockEnabled = true
            local pName = Players:GetPlayerFromCharacter(char) and Players:GetPlayerFromCharacter(char).Name or "Target"
            Rayfield:Notify({Title = "Combat", Content = "Цель заблокирована: " .. pName, Duration = 2})
         else
            Rayfield:Notify({Title = "Combat", Content = "Нет целей в FOV для фиксации!", Duration = 2})
         end
      end
   end,
})

MainTab:CreateToggle({
   Name = "Wall Check",
   CurrentValue = true,
   Callback = function(Value) _G.WallCheck = Value end,
})

MainTab:CreateDropdown({
   Name = "Target Part",
   Options = {"Head", "HumanoidRootPart"},
   CurrentOption = {"Head"},
   MultipleOptions = false,
   Callback = function(Option) _G.TargetPart = Option[1] end,
})

MainTab:CreateSection("Target ESP Customization")

MainTab:CreateDropdown({
   Name = "Target ESP Origin (Расположение)",
   Options = {"Target Part", "Mouse"},
   CurrentOption = {"Target Part"},
   MultipleOptions = false,
   Callback = function(Option) _G.TargetESPOrigin = Option[1] end,
})

MainTab:CreateColorPicker({
    Name = "Target ESP Color",
    Color = _G.TargetESPColor,
    Callback = function(Value) _G.TargetESPColor = Value end
})

MainTab:CreateSlider({
   Name = "Target ESP Thickness",
   Range = {1, 5},
   Increment = 1,
   CurrentValue = 2,
   Callback = function(Value) _G.TargetESPThickness = Value end,
})

MainTab:CreateSlider({
   Name = "Target ESP Gap (Расстояние)",
   Range = {0, 100},
   Increment = 1,
   CurrentValue = 20,
   Callback = function(Value) _G.TargetESPGap = Value end,
})

MainTab:CreateSlider({
   Name = "Target ESP Size (Длина усов)",
   Range = {5, 50},
   Increment = 1,
   CurrentValue = 15,
   Callback = function(Value) _G.TargetESPSize = Value end,
})

MainTab:CreateSlider({
   Name = "Target ESP Speed",
   Range = {0, 720},
   Increment = 10,
   CurrentValue = 150,
   Callback = function(Value) _G.TargetESPSpeed = Value end,
})

MainTab:CreateSection("Hitboxes")

MainTab:CreateKeybind({
   Name = "Hitbox Keybind",
   CurrentKeybind = "H",
   HoldToInteract = false,
   FileFolder = "NurikaHubSettings",
   Callback = function(Key)
      _G.HitboxEnabled = not _G.HitboxEnabled
      Rayfield:Notify({Title = "Combat", Content = "Hitboxes: " .. (_G.HitboxEnabled and "ON" or "OFF"), Duration = 2})
   end,
})

MainTab:CreateSlider({
   Name = "Hitbox Size",
   Range = {1, 100},
   Increment = 1,
   CurrentValue = 40,
   Callback = function(Value) _G.HitboxSize = Value end,
})


VisualsTab:CreateSection("Visual Customization")
VisualsTab:CreateColorPicker({
    Name = "Visuals Color",
    Color = _G.GlobalThemeColor,
    Callback = function(Value) _G.GlobalThemeColor = Value end
})

VisualsTab:CreateSlider({
   Name = "Field of View",
   Range = {70, 120},
   Increment = 1,
   CurrentValue = 70,
   Callback = function(Value) _G.CameraFOV = Value end,
})

VisualsTab:CreateSection("Effects")
VisualsTab:CreateToggle({
   Name = "Enable Land Wave",
   CurrentValue = true,
   Callback = function(Value) _G.LandEffect = Value end,
})

VisualsTab:CreateDropdown({
   Name = "Wave Style",
   Options = {"Filled", "Ring"},
   CurrentOption = {"Filled"},
   MultipleOptions = false,
   Callback = function(Option) _G.WaveStyle = Option[1] end,
})

VisualsTab:CreateSection("Player ESP")
VisualsTab:CreateToggle({
   Name = "Chams",
   CurrentValue = false,
   Callback = function(Value) 
      _G.Chams = Value 
      if not Value then
         for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("v_Chams") then p.Character.v_Chams:Destroy() end
         end
      end
   end,
})

VisualsTab:CreateToggle({
   Name = "Show Names",
   CurrentValue = false,
   Callback = function(Value) _G.Names = Value end,
})

VisualsTab:CreateToggle({
   Name = "Enable Tracers",
   CurrentValue = false,
   Callback = function(Value) _G.Tracers = Value end,
})

VisualsTab:CreateDropdown({
   Name = "Tracer Origin",
   Options = {"Top", "Bottom", "Mouse"},
   CurrentOption = {"Bottom"},
   MultipleOptions = false,
   Callback = function(Option) _G.TracerOrigin = Option[1] end,
})

VisualsTab:CreateButton({
   Name = "Force Clean Visuals",
   Callback = function()
      for i, v in pairs(PlayerTracers) do v.Visible = false end
      for i, v in pairs(PlayerNames) do v.Visible = false end
      for _, p in pairs(Players:GetPlayers()) do
          if p.Character and p.Character:FindFirstChild("v_Chams") then p.Character.v_Chams:Destroy() end
      end
   end,
})


MoveTab:CreateSection("Character Physical")
MoveTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 300},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(Value) _G.WalkSpeed = Value end,
})

MoveTab:CreateSlider({
   Name = "JumpPower",
   Range = {50, 500},
   Increment = 1,
   CurrentValue = 50,
   Callback = function(Value) _G.JumpPower = Value end,
})

MoveTab:CreateSection("Strafing")
MoveTab:CreateToggle({
   Name = "Enable Fast Strafe",
   CurrentValue = false,
   Callback = function(Value) _G.FastStrafe = Value end,
})
MoveTab:CreateSlider({
   Name = "Strafe Speed",
   Range = {1, 300},
   Increment = 1,
   CurrentValue = 50,
   Callback = function(Value) _G.StrafeSpeed = Value end,
})

MoveTab:CreateSection("Fly & Noclip")
MoveTab:CreateKeybind({
   Name = "Fly Keybind",
   CurrentKeybind = "F",
   HoldToInteract = false,
   FileFolder = "NurikaHubSettings", 
   Callback = function(Key) ToggleFly(not _G.FlyEnabled) end,
})

MoveTab:CreateSlider({
   Name = "Fly Speed",
   Range = {10, 500},
   Increment = 10,
   CurrentValue = 50,
   Callback = function(Value) _G.FlySpeed = Value end,
})

MoveTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Callback = function(Value) _G.Noclip = Value end,
})


local function DrawTargetESP(centerPos, deltaTime)
    CurrentAngle = CurrentAngle + math.rad(_G.TargetESPSpeed * deltaTime)
    
    local gap = _G.TargetESPGap
    local size = _G.TargetESPSize

    local cos, sin = math.cos(CurrentAngle), math.sin(CurrentAngle)
    local function rotate(x, y)
        return Vector2.new(x * cos - y * sin, x * sin + y * cos)
    end

   
    local topLeft = rotate(-gap, -gap) + centerPos
    local topRight = rotate(gap, -gap) + centerPos
    local bottomRight = rotate(gap, gap) + centerPos
    local bottomLeft = rotate(-gap, gap) + centerPos

    
    local points = {
        {topLeft, topLeft + rotate(size, 0)}, {topLeft, topLeft + rotate(0, size)},
        {topRight, topRight + rotate(-size, 0)}, {topRight, topRight + rotate(0, size)},
        {bottomRight, bottomRight + rotate(-size, 0)}, {bottomRight, bottomRight + rotate(0, -size)},
        {bottomLeft, bottomLeft + rotate(size, 0)}, {bottomLeft, bottomLeft + rotate(0, -size)}
    }

    for i = 1, 8 do
        IndicatorLines[i].From = points[i][1]
        IndicatorLines[i].To = points[i][2]
        IndicatorLines[i].Color = _G.TargetESPColor
        IndicatorLines[i].Thickness = _G.TargetESPThickness
        IndicatorLines[i].Visible = true
    end
end


local function PlayLandEffect(pos)
    if not _G.LandEffect then return end
    local wave = Instance.new("Part")
    wave.Parent = workspace
    wave.Anchored = true
    wave.CanCollide = false
    wave.Color = _G.GlobalThemeColor
    wave.Material = Enum.Material.Neon
    wave.Transparency = 0.3
    local groundPos = pos - Vector3.new(0, 3, 0)
    if _G.WaveStyle == "Filled" then
        wave.Shape = Enum.PartType.Cylinder
        wave.CFrame = CFrame.new(groundPos) * CFrame.Angles(0, 0, math.rad(90))
        wave.Size = Vector3.new(0.1, 1, 1)
        TweenService:Create(wave, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = Vector3.new(0.1, 16, 16), Transparency = 1}):Play()
    else
        wave.CFrame = CFrame.new(groundPos) * CFrame.Angles(math.rad(90), 0, 0)
        wave.Size = Vector3.new(1, 1, 0.1)
        local mesh = Instance.new("SpecialMesh", wave)
        mesh.MeshType = Enum.MeshType.FileMesh
        mesh.MeshId = "rbxassetid://3270017"
        mesh.Scale = Vector3.new(1, 1, 0.1)
        TweenService:Create(mesh, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Scale = Vector3.new(16, 16, 0.1)}):Play()
        TweenService:Create(wave, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Transparency = 1}):Play()
    end
    task.delay(0.6, function() wave:Destroy() end)
end


RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Humanoid") then return end
    local hum = char.Humanoid
    local hrp = char:FindFirstChild("HumanoidRootPart")

    Camera.FieldOfView = _G.CameraFOV
    hum.WalkSpeed = _G.WalkSpeed
    hum.JumpPower = _G.JumpPower
    hum.UseJumpPower = true 

    if _G.Noclip then
        for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end

    
    if _G.FlyEnabled and hrp then
        local bv = hrp:FindFirstChild("FlyVelocity")
        local bg = hrp:FindFirstChild("FlyGyro")
        if bv and bg then
            local dir = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
            
            bv.Velocity = dir * _G.FlySpeed
            bg.CFrame = Camera.CFrame
        end
    end

    
    if _G.FastStrafe and hrp and not _G.FlyEnabled then
        if hum.MoveDirection.Magnitude > 0 then
            local rightVec = Camera.CFrame.RightVector
            if math.abs(hum.MoveDirection:Dot(rightVec)) > 0.1 then
                hrp.Velocity = Vector3.new(hum.MoveDirection.X * _G.StrafeSpeed, hrp.Velocity.Y, hum.MoveDirection.Z * _G.StrafeSpeed)
            end
        end
    end

    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            if _G.HitboxEnabled then
                head.Size = Vector3.new(_G.HitboxSize, _G.HitboxSize, _G.HitboxSize)
                head.Transparency = 0.7
                head.CanCollide = false; head.CanTouch = false; head.CanQuery = true; head.Massless = true
            else
                head.Size = Vector3.new(1, 1, 1); head.Transparency = 0; head.CanCollide = true; head.Massless = false
            end
        end
    end
end)


RunService.RenderStepped:Connect(function(deltaTime)
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = _G.AimbotFOV

    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if not PlayerTracers[p] then
                PlayerTracers[p] = Drawing.new("Line")
                PlayerNames[p] = Drawing.new("Text")
                PlayerNames[p].Size = 13; PlayerNames[p].Center = true; PlayerNames[p].Outline = true
            end
            
            local line, text = PlayerTracers[p], PlayerNames[p]
            local vis, nVis = false, false
            
            if p.Character and p.Character:FindFirstChild("Head") then
                local head = p.Character.Head
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                
                if onScreen and pos.Z > 0 then
                    if _G.Tracers then
                        local start = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                        if _G.TracerOrigin == "Top" then start = Vector2.new(Camera.ViewportSize.X/2, 0)
                        elseif _G.TracerOrigin == "Mouse" then start = UserInputService:GetMouseLocation() end
                        line.From = start; line.To = Vector2.new(pos.X, pos.Y)
                        line.Color = _G.GlobalThemeColor; vis = true
                    end
                    if _G.Names then
                        text.Position = Vector2.new(pos.X, pos.Y - 35)
                        text.Text = p.Name:lower(); text.Color = _G.GlobalThemeColor; nVis = true
                    end
                    if _G.Chams then
                        local h = p.Character:FindFirstChild("v_Chams") or Instance.new("Highlight", p.Character)
                        h.Name = "v_Chams"; h.FillColor = _G.GlobalThemeColor
                    end
                end
            end
            line.Visible = vis; text.Visible = nVis
        end
    end
    
    
    local isAimbotActive = _G.Aimbot and (IsRMBDown or _G.TargetLockEnabled)
    
    if isAimbotActive then
        local targetPart, _ = GetClosestPlayer()
        if targetPart then
           
            local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
            if _G.AimbotSmooth <= 1 then
                Camera.CFrame = targetCFrame
            else
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 / _G.AimbotSmooth)
            end

           
            local centerPos = nil
            if _G.TargetESPOrigin == "Mouse" then
                centerPos = UserInputService:GetMouseLocation()
            else
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then centerPos = Vector2.new(screenPos.X, screenPos.Y) end
            end

            
            if centerPos then
                DrawTargetESP(centerPos, deltaTime)
            else
                for _, l in pairs(IndicatorLines) do l.Visible = false end
            end
        else
            for _, l in pairs(IndicatorLines) do l.Visible = false end
        end
    else
        for _, l in pairs(IndicatorLines) do l.Visible = false end
    end
end)


local function SetupCharacter(char)
    local hum = char:WaitForChild("Humanoid")
    hum.StateChanged:Connect(function(_, new)
        if new == Enum.HumanoidStateType.Landed then PlayLandEffect(char.HumanoidRootPart.Position) end
    end)
end

LocalPlayer.CharacterAdded:Connect(SetupCharacter)
if LocalPlayer.Character then SetupCharacter(LocalPlayer.Character) end

Rayfield:Notify({Title = "ти на рат", Content = "затру орижинал буст", Duration = 4})
