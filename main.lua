local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "никита кравч хаб",
   LoadingTitle = "loading ольга",
   LoadingSubtitle = "by димасик",
   ConfigurationSaving = { Enabled = false },
   Theme = "AmberGlow" 
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Глобальные переменные
_G.Aimbot = false
_G.WallCheck = true
_G.HitboxEnabled = false
_G.HitboxSize = 40
_G.Chams = false
_G.Tracers = false
_G.Names = false
_G.TracerOrigin = "Bottom"
_G.FOV = 100
_G.TargetPart = "Head"
_G.FlyEnabled = false
_G.FlySpeed = 50
_G.Noclip = false
_G.FastStrafe = false
_G.StrafeSpeed = 50
_G.LandEffect = true
_G.WaveStyle = "Filled" 
_G.ChinaHat = false -- Изначально выключена!

local GlobalThemeColor = Color3.fromRGB(0, 255, 255)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Visible = false

local PlayerTracers = {}
local PlayerNames = {}

-- Вкладки
local MainTab = Window:CreateTab("Combat", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local MoveTab = Window:CreateTab("Movement", 4483362458)

-- COMBAT
MainTab:CreateToggle({
   Name = "Enable Aimbot",
   CurrentValue = false,
   Callback = function(Value) _G.Aimbot = Value; FOVCircle.Visible = Value end,
})

MainTab:CreateToggle({
   Name = "Wall Check",
   CurrentValue = true,
   Callback = function(Value) _G.WallCheck = Value end,
})

MainTab:CreateSection("Hitboxes")
MainTab:CreateToggle({
   Name = "Enable Hitbox Expander",
   CurrentValue = false,
   Callback = function(Value) _G.HitboxEnabled = Value end,
})
MainTab:CreateSlider({
   Name = "Hitbox Size",
   Range = {1, 100},
   Increment = 1,
   CurrentValue = 40,
   Callback = function(Value) _G.HitboxSize = Value end,
})

MainTab:CreateDropdown({
   Name = "Target Part",
   Options = {"Head", "HumanoidRootPart"},
   CurrentOption = {"Head"},
   MultipleOptions = false,
   Callback = function(Option) _G.TargetPart = Option[1] end,
})

MainTab:CreateSlider({
   Name = "FOV Radius",
   Range = {10, 600},
   Increment = 5,
   CurrentValue = 100,
   Callback = function(Value) _G.FOV = Value end,
})

-- VISUALS
VisualsTab:CreateToggle({
   Name = "China Hat",
   CurrentValue = false,
   Callback = function(Value) 
      _G.ChinaHat = Value 
   end,
})

VisualsTab:CreateButton({
   Name = "Force Clean Visuals",
   Callback = function()
      for i, v in pairs(PlayerTracers) do v.Visible = false; v:Remove() end
      table.clear(PlayerTracers)
      for i, v in pairs(PlayerNames) do v.Visible = false; v:Remove() end
      table.clear(PlayerNames)
      for _, p in pairs(Players:GetPlayers()) do
         if p.Character and p.Character:FindFirstChild("v_Chams") then p.Character.v_Chams:Destroy() end
      end
      _G.Tracers = false; _G.Names = false; _G.Chams = false
   end,
})

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

VisualsTab:CreateSection("Tracers Settings")
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

-- MOVEMENT
MoveTab:CreateToggle({
   Name = "Fly",
   CurrentValue = false,
   Callback = function(Value)
      _G.FlyEnabled = Value
      local char = LocalPlayer.Character
      if Value and char and char:FindFirstChild("HumanoidRootPart") then
         local bv = char.HumanoidRootPart:FindFirstChild("FlyVelocity") or Instance.new("BodyVelocity", char.HumanoidRootPart)
         bv.Name = "FlyVelocity"
         bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
         bv.Velocity = Vector3.new(0,0,0)
      else
         if char and char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart:FindFirstChild("FlyVelocity") then
            char.HumanoidRootPart.FlyVelocity:Destroy()
         end
      end
   end,
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

MoveTab:CreateSection("Strafing")
MoveTab:CreateToggle({
   Name = "Enable Fast Strafe",
   CurrentValue = false,
   Callback = function(Value) _G.FastStrafe = Value end,
})
MoveTab:CreateSlider({
   Name = "Strafe Speed",
   Range = {1, 200},
   Increment = 1,
   CurrentValue = 50,
   Callback = function(Value) _G.StrafeSpeed = Value end,
})

MoveTab:CreateSection("Land Wave Settings")
MoveTab:CreateToggle({
   Name = "Enable Land Wave",
   CurrentValue = true,
   Callback = function(Value) _G.LandEffect = Value end,
})

MoveTab:CreateDropdown({
   Name = "Wave Style",
   Options = {"Filled", "Ring"},
   CurrentOption = {"Filled"},
   MultipleOptions = false,
   Callback = function(Option) _G.WaveStyle = Option[1] end,
})

-- ФУНКЦИЯ КРУГА
local function PlayLandEffect(pos)
    if not _G.LandEffect then return end
    
    local wave = Instance.new("Part")
    wave.Name = "LandWave"
    wave.Parent = workspace
    wave.Anchored = true
    wave.CanCollide = false
    wave.CastShadow = false
    wave.Color = GlobalThemeColor
    wave.Material = Enum.Material.Neon
    wave.Transparency = 0.3
    
    if _G.WaveStyle == "Filled" then
        wave.Shape = Enum.PartType.Cylinder
        wave.CFrame = CFrame.new(pos - Vector3.new(0, 3, 0)) * CFrame.Angles(0, 0, math.rad(90))
        wave.Size = Vector3.new(0.1, 1, 1)
        TweenService:Create(wave, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = Vector3.new(0.1, 16, 16), Transparency = 1}):Play()
    else
        wave.CFrame = CFrame.new(pos - Vector3.new(0, 3, 0)) * CFrame.Angles(math.rad(90), 0, 0)
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

-- ФУНКЦИЯ CHINA HAT (ПОЛНЫЙ ФИКС ПОЗИЦИИ)
local function CreateChinaHat(char)
    local head = char:WaitForChild("Head", 10)
    if not head then return end
    
    local hat = Instance.new("Part")
    hat.Name = "v_ChinaHat"
    hat.Parent = char
    hat.Size = Vector3.new(0.5, 0.2, 0.5)
    hat.CanCollide = false
    hat.Massless = true
    hat.Color = GlobalThemeColor
    hat.Material = Enum.Material.Neon
    hat.Transparency = 0.3
    
    local mesh = Instance.new("SpecialMesh", hat)
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://1778999"
    mesh.Scale = Vector3.new(1.6, 0.7, 1.6) -- Аккуратный размер

    local weld = Instance.new("Weld", hat)
    weld.Part0 = hat
    weld.Part1 = head
    -- C0 регулирует позицию относительно головы. -0.45 сажает её ровно НА голову.
    weld.C0 = CFrame.new(0, -0.65, -0.1) -- ПОДНЯЛ ВЫШЕ И ВПЕРЕД (НА КОЗЫРЕК)

    RunService.RenderStepped:Connect(function()
        if hat and hat.Parent then
            hat.Visible = _G.ChinaHat -- ТЕПЕРЬ СЛУШАЕТСЯ КНОПКИ
            hat.Color = GlobalThemeColor
        end
    end)
end

-- Логика персонажа
local function SetupCharacter(char)
    CreateChinaHat(char)
    local hum = char:WaitForChild("Humanoid")
    hum.StateChanged:Connect(function(_, new)
        if _G.LandEffect and new == Enum.HumanoidStateType.Landed then
            PlayLandEffect(char.HumanoidRootPart.Position)
        end
    end)
end

-- Вспомогательные функции
local function isVisible(targetPart)
    if not _G.WallCheck then return true end
    local char = LocalPlayer.Character
    if not char then return false end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {char, targetPart.Parent, workspace:FindFirstChild("Terrain")}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(Camera.CFrame.Position, targetPart.Position - Camera.CFrame.Position, params)
    return result == nil
end

local function createESP(player)
    if PlayerTracers[player] then return end
    local line = Drawing.new("Line"); line.Thickness = 1; line.Color = GlobalThemeColor
    PlayerTracers[player] = line
    local text = Drawing.new("Text"); text.Size = 13; text.Center = true; text.Outline = true; text.Color = GlobalThemeColor
    PlayerNames[player] = text
end

-- ОСНОВНОЙ ЦИКЛ
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end

    if _G.Noclip then
        for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
    end
    
    if _G.FastStrafe and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        local hrp = char.HumanoidRootPart
        local hum = char.Humanoid
        if hum.MoveDirection.Magnitude > 0 then
            local rightVec = Camera.CFrame.RightVector
            if math.abs(hum.MoveDirection:Dot(rightVec)) > 0.1 then
                hrp.Velocity = Vector3.new(hum.MoveDirection.X * _G.StrafeSpeed, hrp.Velocity.Y, hum.MoveDirection.Z * _G.StrafeSpeed)
            end
        end
    end

    if _G.FlyEnabled and char:FindFirstChild("HumanoidRootPart") then
        local bv = char.HumanoidRootPart:FindFirstChild("FlyVelocity")
        if bv then
            local dir = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
            bv.Velocity = dir * _G.FlySpeed
        end
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local h = p.Character.Head
            h.Size = _G.HitboxEnabled and Vector3.new(_G.HitboxSize, _G.HitboxSize, _G.HitboxSize) or Vector3.new(1,1,1)
            h.Transparency = _G.HitboxEnabled and 0.7 or 0
            h.CanCollide = false
        end
    end
end)

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation(); FOVCircle.Radius = _G.FOV

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            createESP(p)
            local line, text = PlayerTracers[p], PlayerNames[p]
            local vis, nameVis = false, false
            
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = p.Character.HumanoidRootPart
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    if _G.Tracers then
                        local startPos = (_G.TracerOrigin == "Top" and Vector2.new(Camera.ViewportSize.X/2, 0)) or (_G.TracerOrigin == "Mouse" and UserInputService:GetMouseLocation()) or Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                        line.From = startPos; line.To = Vector2.new(pos.X, pos.Y); vis = true
                    end
                    if _G.Names then text.Position = Vector2.new(pos.X, pos.Y - 30); text.Text = p.Name:lower(); nameVis = true end
                    if _G.Chams then
                        local h = p.Character:FindFirstChild("v_Chams") or Instance.new("Highlight", p.Character)
                        h.Name = "v_Chams"; h.FillColor = GlobalThemeColor
                    end
                end
            end
            line.Visible = vis; text.Visible = nameVis
        end
    end

    if _G.Aimbot then
        local closest, dist = nil, _G.FOV
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(_G.TargetPart) then
                local part = p.Character[_G.TargetPart]
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                    if mag < dist and isVisible(part) then dist = mag; closest = part end
                end
            end
        end
        if closest then Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Position) end
    end
end)

LocalPlayer.CharacterAdded:Connect(SetupCharacter)
if LocalPlayer.Character then SetupCharacter(LocalPlayer.Character) end

Rayfield:Notify({Title = "Ready", Content = "сделано на нейронке by гг ден", Duration = 3})
