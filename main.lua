local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()


local GitHubKeysURL = "https://raw.githubusercontent.com/kamapidor228/key.txt/refs/heads/main/key.txt"

local Window = Rayfield:CreateWindow({
   Name = "rodzinka hub",
   LoadingTitle = "loading petja",
   LoadingSubtitle = "by jaroslaw бедный",
   ConfigurationSaving = { Enabled = false },
   Theme = "AmberGlow",
   KeySystem = true,
   KeySettings = {
      Title = "Key System",
      Subtitle = "Get key from Linkvertise",
    
      Note = "https://link-center.net/3666502/5DDDXI8BXlqk", 
      FileName = "RodzinkaHubKey",
      SaveKey = true,
      GrabKeyFromSite = false,
      
      Key = loadstring(game:HttpGet(GitHubKeysURL))()
   }
})


local MainTab = Window:CreateTab("Combat", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)

MainTab:CreateToggle({
   Name = "Enable Aimbot",
   CurrentValue = false,
   Callback = function(Value) 
       _G.Aimbot = Value 
       Rayfield:Notify({Title = "Aimbot", Content = "Status: " .. tostring(Value)})
   end,
})

