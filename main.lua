local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local RawKeyURL = "https://raw.githubusercontent.com/kamapidor228/petja/refs/heads/main/key.txt"
local LinkvertiseURL = "https://link-center.net/3666502/5DDDXI8BXlqk"

local CorrectKey = game:HttpGet(RawKeyURL):gsub("%s+", "")

local KeyWindow = Rayfield:CreateWindow({
   Name = "Key System | rodzinka hub",
   LoadingTitle = "Checking Access...",
   LoadingSubtitle = "by jaroslaw бедный",
   ConfigurationSaving = { Enabled = false },
   Theme = "AmberGlow"
})

local KeyTab = KeyWindow:CreateTab("Verification", 4483362458)

local function StartMainScript()
    local Window = Rayfield:CreateWindow({
       Name = "rodzinka hub",
       LoadingTitle = "loading petja",
       LoadingSubtitle = "by jaroslaw бедный",
       ConfigurationSaving = { Enabled = false },
       Theme = "AmberGlow" 
    })

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    _G.Aimbot = false
    _G.TargetPart = "Head"
    _G.FOV = 100
    _G.FlyEnabled = false
    _G.FlySpeed = 50

    local MainTab = Window:CreateTab("Aimbot", 4483362458)
    local MoveTab = Window:CreateTab("Movement", 4483362458)

    MainTab:CreateToggle({
       Name = "Enable Aimbot",
       CurrentValue = false,
       Callback = function(Value) _G.Aimbot = Value end,
    })

    MainTab:CreateDropdown({
       Name = "Target Part",
       Options = {"Head", "HumanoidRootPart"},
       CurrentOption = {"Head"},
       Callback = function(Option) _G.TargetPart = Option[1] end,
    })

    MoveTab:CreateToggle({
       Name = "Fly",
       CurrentValue = false,
       Callback = function(Value)
          _G.FlyEnabled = Value
          local char = LocalPlayer.Character
          if Value and char and char:FindFirstChild("HumanoidRootPart") then
             local bv = Instance.new("BodyVelocity", char.HumanoidRootPart)
             bv.Name = "FlyVelocity"
             bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
          else
             if char and char.HumanoidRootPart:FindFirstChild("FlyVelocity") then
                char.HumanoidRootPart.FlyVelocity:Destroy()
             end
          end
       end,
    })

    RunService.RenderStepped:Connect(function()
        if _G.Aimbot then
            local closest = nil
            local shortDist = _G.FOV
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(_G.TargetPart) then
                    local part = p.Character[_G.TargetPart]
                    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                        if mag < shortDist then shortDist = mag; closest = part end
                    end
                end
            end
            if closest then Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Position) end
        end
    end)
end

KeyTab:CreateInput({
   Name = "Enter Key",
   PlaceholderText = "Paste key here...",
   Callback = function(Text)
      if Text == CorrectKey then
         Rayfield:Notify({Title = "Correct!", Content = "Access Granted!", Duration = 3})
         KeyWindow:Destroy()
         StartMainScript()
      else
         Rayfield:Notify({Title = "Error!", Content = "Wrong key!", Duration = 3})
      end
   end,
})

KeyTab:CreateButton({
   Name = "Get Key (Copy Link)",
   Callback = function()
      setclipboard(LinkvertiseURL)
      Rayfield:Notify({Title = "Copied!", Content = "Link copied to clipboard.", Duration = 5})
   end,
})
