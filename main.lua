local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local RawKeyURL = "https://raw.githubusercontent.com/kamapidor228/key.txt/refs/heads/main/key.txt"
local LinkvertiseURL = "https://link-center.net/3666502/5DDDXI8BXlqk"

local CorrectKey = game:HttpGet(RawKeyURL):gsub("%s+", "")

local KeyWindow = Rayfield:CreateWindow({
    Name = "Key System | Rodzinka Hub",
    LoadingTitle = "Verification",
    LoadingSubtitle = "by jaroslaw poor",
    ConfigurationSaving = { Enabled = false },
    Theme = "AmberGlow" 
})

local KeyTab = KeyWindow:CreateTab("Verification", 4483362458)

KeyTab:CreateInput({
    Name = "Enter Key",
    PlaceholderText = "Paste key here...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        if Text == CorrectKey then
            Rayfield:Notify({Title = "Success", Content = "Access Granted!", Duration = 2})
            
            KeyWindow:Destroy()
            
            local Window = Rayfield:CreateWindow({
                Name = "Rodzinka Hub",
                LoadingTitle = "Loading Petja...",
                LoadingSubtitle = "by jaroslaw poor",
                ConfigurationSaving = { Enabled = false },
                Theme = "AmberGlow" 
            })

            local MainTab = Window:CreateTab("Combat", 4483362458)
            local VisualsTab = Window:CreateTab("Visuals", 4483362458)
            local MoveTab = Window:CreateTab("Movement", 4483362458)

            MainTab:CreateToggle({
                Name = "Enable Aimbot",
                CurrentValue = false,
                Callback = function(Value) _G.Aimbot = Value end,
            })

            MoveTab:CreateToggle({
                Name = "Fly",
                CurrentValue = false,
                Callback = function(Value)
                    _G.FlyEnabled = Value
                    local char = game.Players.LocalPlayer.Character
                    if Value and char and char:FindFirstChild("HumanoidRootPart") then
                        local bv = Instance.new("BodyVelocity", char.HumanoidRootPart)
                        bv.Name = "FlyVelocity"
                        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        bv.Velocity = Vector3.new(0,0,0)
                    else
                        if char and char.HumanoidRootPart:FindFirstChild("FlyVelocity") then
                            char.HumanoidRootPart.FlyVelocity:Destroy()
                        end
                    end
                end,
            })
            
            MainTab:CreateLabel("Script loaded!")
        else
            Rayfield:Notify({Title = "Error", Content = "Wrong Key!", Duration = 3})
        end
    end,
})

KeyTab:CreateButton({
    Name = "Get Key",
    Callback = function()
        setclipboard(LinkvertiseURL)
        Rayfield:Notify({Title = "Copied", Content = "Link copied!", Duration = 5})
    end,
})
