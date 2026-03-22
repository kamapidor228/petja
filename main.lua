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
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

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

local GlobalThemeColor = Color3.fromRGB(0, 255, 255)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Visible = false

local PlayerTracers = {}
local PlayerNames = {}

local MainTab = Window:CreateTab("Combat", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local MoveTab = Window:CreateTab("Movement", 4483362458)

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

MainTab:CreateSection("Settings")

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

VisualsTab:CreateSection("Tracers")

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

local function isVisible(targetPart)
    if not _G.WallCheck then return true end
    local char = LocalPlayer.Character
    if not char then return false end
    
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {char, targetPart.Parent, workspace:FindFirstChild("Terrain")}
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true
    
    local result = workspace:Raycast(Camera.CFrame.Position, targetPart.Position - Camera.CFrame.Position, params)
    return result == nil
end

local function createESP(player)
    if PlayerTracers[player] then return end
    local line = Drawing.new("Line")
    line.Thickness = 1
    line.Color = GlobalThemeColor
    line.Transparency = 0.6
    PlayerTracers[player] = line
    local text = Drawing.new("Text")
    text.Size = 13
    text.Center = true
    text.Outline = true
    text.Font = 3
    text.Color = GlobalThemeColor
    PlayerNames[player] = text
end

RunService.Stepped:Connect(function()
    if _G.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            if _G.HitboxEnabled then
                head.Size = Vector3.new(_G.HitboxSize, _G.HitboxSize, _G.HitboxSize)
                head.Transparency = 0.7
                head.CanCollide = false
            else
                head.Size = Vector3.new(1, 1, 1)
                head.Transparency = 0
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = _G.FOV

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            createESP(p)
            local line = PlayerTracers[p]
            local text = PlayerNames[p]
            local visibleState, nameState = false, false
            
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Head") then
                local hrp = p.Character.HumanoidRootPart
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                
                if onScreen then
                    if _G.Tracers then
                        local startPos
                        if _G.TracerOrigin == "Top" then 
                            startPos = Vector2.new(Camera.ViewportSize.X/2, 0)
                        elseif _G.TracerOrigin == "Mouse" then 
                            startPos = UserInputService:GetMouseLocation()
                        else 
                            startPos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y) 
                        end
                        
                        line.From = startPos
                        line.To = Vector2.new(screenPos.X, screenPos.Y)
                        visibleState = true
                    end
                    
                    if _G.Names then
                        local headPos = Camera:WorldToViewportPoint(p.Character.Head.Position + Vector3.new(0, 2.5, 0))
                        text.Position = Vector2.new(headPos.X, headPos.Y)
                        text.Text = string.lower(p.Name)
                        nameState = true
                    end
                    
                    if _G.Chams then
                        local h = p.Character:FindFirstChild("v_Chams") or Instance.new("Highlight", p.Character)
                        h.Name = "v_Chams"
                        h.FillColor = GlobalThemeColor
                        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    end
                end
            end
            line.Visible = visibleState
            text.Visible = nameState
        end
    end

    if _G.FlyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local bv = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("FlyVelocity")
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

    if _G.Aimbot then
        local closest, shortDist = nil, _G.FOV
        local center = UserInputService:GetMouseLocation()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(_G.TargetPart) then
                local part = p.Character[_G.TargetPart]
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if mag < shortDist and isVisible(part) then shortDist = mag; closest = part end
                end
            end
        end
        if closest then Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Position) end
    end
end)
