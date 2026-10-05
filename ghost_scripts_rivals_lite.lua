-- ================================================================
--  GHOST SCRIPTS | RIVALS - FULL SUITE (FINAL)
--  By @ghost.sceipts.01
--  YouTube: https://youtube.com/@ghost.scripts.01
--  Bypass + Aimbot + Silent Aim + ESP + Movement + FPS
-- ================================================================

-- ================================================================
--  BYPASS ANTI-CHEAT (VERSÃO SUAVE - SEM CRASH)
-- ================================================================

local hookmetamethod = hookmetamethod
local getrawmetatable = getrawmetatable
local setreadonly = setreadonly
local checkcaller = checkcaller
local getnamecallmethod = getnamecallmethod
local getconnections = getconnections

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    local ok, plr = pcall(function() return Players:GetPropertyChangedSignal("LocalPlayer"):Wait() end)
    if ok and plr then LocalPlayer = plr end
end
if not LocalPlayer then
    pcall(function() LocalPlayer = Players.PlayerAdded:Wait() end)
end
getgenv().Players = Players
getgenv().ReplicatedStorage = ReplicatedStorage
getgenv().LocalPlayer = LocalPlayer
_G.Players = Players
_G.ReplicatedStorage = ReplicatedStorage
_G.LocalPlayer = LocalPlayer

pcall(function()
    local mt = getrawmetatable(game)
    if mt then
        setreadonly(mt, false)

        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()

            if method == "Kick" and self == LocalPlayer then
                return
            end

            if method == "FireServer" or method == "InvokeServer" then
                if typeof(self) == "Instance" and self.Name then
                    local name = self.Name:lower()
                    if name:find("anticheat") or name:find("detection") or name:find("integrity") then
                        return
                    end
                end
            end

            return oldNamecall(self, ...)
        end)

        setreadonly(mt, true)
    end
end)

pcall(function()
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", function(self, key)
        if checkcaller() and key == "Kick" and self == LocalPlayer then
            return function() end
        end
        return oldIndex(self, key)
    end)
end)

task.spawn(function()
    task.wait(1)
    pcall(function()
        if not getconnections then return end

        local function isACScript(s)
            if not s then return false end
            local n = tostring(s):lower()
            return n:find("anticheat") or n:find("ac_") or n:find("bansystem")
        end

        for _, conn in ipairs(getconnections(LocalPlayer.CharacterAdded)) do
            pcall(function()
                if not checkcaller() then
                    local fn = conn.Function
                    if fn and isACScript(fn) then
                        conn:Disable()
                    end
                end
            end)
        end
    end)
end)

ReplicatedStorage.DescendantAdded:Connect(function(obj)
    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
        local name = obj.Name:lower()
        if name == "anticheat" or name == "detection" or name == "integrity" then
            pcall(function() obj:Destroy() end)
        end
    end
end)

-- ================================================================
--  INFO DO CRIADOR
-- ================================================================

getgenv().ScriptInfo = {
    Creator = "ghost Scripts",
    Handle = "@ghost.sceipts.01",
    YouTube = "https://youtube.com/@ghost.scripts.01?si=y_ZReiiu1cuLc2O1",
    PanelName = "ghost Scripts",
}

-- ================================================================
--  NOTIFICAÇÕES E HELPERS
-- ================================================================

local function SendGriefNotify(title, text, time)
    time = time or 5
    pcall(function()
        if Library and Library.Notify then
            Library:Notify({ Title = title, Description = text, Time = time })
            return true
        end
        return false
    end)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", { Title = title, Text = text, Duration = time })
    end)
    print("[" .. tostring(title) .. "] " .. tostring(text))
end
getgenv().SendGriefNotify = SendGriefNotify

local function ShowLoadingNotification()
    SendGriefNotify("ghost Scripts", "Loading script, please wait", 5)
    return function() end
end

getgenv().ModuleCache = getgenv().ModuleCache or {}

local function SafeRequire(moduleRef, timeoutSec)
    local cache = getgenv().ModuleCache
    local key = typeof(moduleRef) == "Instance" and moduleRef:GetFullName() or tostring(moduleRef)
    if cache[key] ~= nil then return cache[key] end
    local deadline = timeoutSec and (os.clock() + timeoutSec) or math.huge
    local lastErr
    while os.clock() < deadline do
        if typeof(moduleRef) == "Instance" and not moduleRef.Parent then
            task.wait(0.1)
        else
            local ok, result = pcall(require, moduleRef)
            if ok then
                cache[key] = result
                return result
            end
            lastErr = result
            task.wait(0.1)
        end
    end
    error("[ghost] module load failed: " .. key .. " (" .. tostring(lastErr) .. ")")
end

getgenv().Require = SafeRequire
getgenv().SafeRequire = SafeRequire
_G.SafeRequire = SafeRequire
SafeRequire = SafeRequire

local function PreloadCoreModules()
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local players = game:GetService("Players")
    local localPlayer = players.LocalPlayer or players.PlayerAdded:Wait()
    local playerScripts = localPlayer:WaitForChild("PlayerScripts", 8)
    local modulesFolder = replicatedStorage:WaitForChild("Modules", 8)
    pcall(function() SafeRequire(modulesFolder:WaitForChild("EnumLibrary", 4)) end)
    pcall(function() SafeRequire(modulesFolder:WaitForChild("Utility", 4)) end)
    local controllers = playerScripts:WaitForChild("Controllers", 8)
    pcall(function() SafeRequire(controllers:WaitForChild("FighterController", 4)) end)
    pcall(function() SafeRequire(controllers:WaitForChild("CameraController", 4)) end)
end

local function HideErrorPromptsStep()
    local coreGui = game:GetService("CoreGui")
    local robloxGui = coreGui:FindFirstChild("RobloxGui")
    if robloxGui then
        local errorPrompt = robloxGui:FindFirstChild("ErrorPrompt")
        if errorPrompt and errorPrompt:IsA("GuiObject") then
            errorPrompt.Visible = false
        end
    end
    local promptGui = coreGui:FindFirstChild("RobloxPromptGui")
    if promptGui and promptGui:IsA("GuiObject") then
        promptGui.Visible = false
    end
end

local function RunLoadingBootstrap()
    RunService = RunService or game:GetService('RunService')
    Players = Players or game:GetService('Players')
    Workspace = Workspace or game:GetService('Workspace')
    local runService = game:GetService("RunService")
    local dismissLoading = ShowLoadingNotification()
    local hideErrors = true
    local hideConn = runService.RenderStepped:Connect(function()
        if hideErrors then HideErrorPromptsStep() end
    end)

    task.wait(0.8)

    pcall(PreloadCoreModules)

    hideErrors = false
    if hideConn then hideConn:Disconnect() hideConn = nil end
    if dismissLoading then dismissLoading() end
end

local RunService = game:GetService("RunService")
RunLoadingBootstrap()
local UserInputService = game:GetService("UserInputService")

pcall(function()
    if setfpscap then setfpscap(0) end
end)

getgenv().SliderFillState = getgenv().SliderFillState or {}
getgenv().SliderFollowRate = getgenv().SliderFollowRate or 11

getgenv().SetSliderFill = function(fill, targetX, hideBorder, sliderObj, forceSnap)
    if not fill or not fill.Parent then return end
    targetX = math.floor(tonumber(targetX) or 0)
    local stateMap = getgenv().SliderFillState
    if forceSnap then
        fill.Size = UDim2.new(0, targetX, 1, 0)
        if hideBorder and sliderObj then
            hideBorder.Visible = not (targetX == sliderObj.MaxSize or targetX == 0)
        end
        stateMap[fill] = nil
        return
    end
    local st = stateMap[fill]
    if st then
        st.target = targetX
        st.hideBorder = hideBorder
        st.sliderObj = sliderObj
    else
        stateMap[fill] = { target = targetX, pos = fill.Size.X.Offset, hideBorder = hideBorder, sliderObj = sliderObj }
    end
end

local tabIconUrls = {
    ["combat"]    = "https://raw.githubusercontent.com/lucide-icons/lucide/refs/heads/main/icons/swords.svg",
    ["character"] = "https://raw.githubusercontent.com/lucide-icons/lucide/refs/heads/main/icons/person-standing.svg",
    ["visuals"]   = "https://raw.githubusercontent.com/lucide-icons/lucide/refs/heads/main/icons/eye.svg",
    ["fps"]       = "https://raw.githubusercontent.com/lucide-icons/lucide/refs/heads/main/icons/zap.svg",
    ["misc"]      = "https://raw.githubusercontent.com/lucide-icons/lucide/refs/heads/main/icons/circle-ellipsis.svg",
    ["settings"]  = "https://raw.githubusercontent.com/lucide-icons/lucide/refs/heads/main/icons/settings.svg",
}

local iconFolder = "ghostScripts"
local iconSubFolder = iconFolder .. "/icons"

if not isfolder(iconFolder) then makefolder(iconFolder) end
if not isfolder(iconSubFolder) then makefolder(iconSubFolder) end

local function buildRasterUrl(svgUrl)
    return "https://wsrv.nl/?url=" .. svgUrl:gsub("https://", "") .. "&w=128&h=128&output=png&tint=ffffff"
end

local function isPngData(data)
    return type(data) == "string" and #data >= 8
        and data:sub(1, 8) == "\137PNG\r\n\026\n"
end

local function requestIconData(url)
    local request = (syn and syn.request) or request or http_request
    if request then
        local ok, response = pcall(request, { Url = url, Method = "GET" })
        if ok and response and response.StatusCode == 200 and isPngData(response.Body) then
            return response.Body
        end
    end
    local ok, data = pcall(function() return game:HttpGet(url) end)
    if ok and isPngData(data) then return data end
end

local function loadIcon(name, svgUrl)
    local path = iconSubFolder .. "/" .. name .. ".png"
    if isfile(path) then
        local valid, cachedData = pcall(readfile, path)
        if not valid or not isPngData(cachedData) then
            pcall(delfile, path)
        end
    end
    if not isfile(path) then
        local data = requestIconData(buildRasterUrl(svgUrl))
        if not data then return nil end
        pcall(writefile, path, data)
    end
    for _, assetLoader in ipairs({ getcustomasset, getsynasset }) do
        if assetLoader then
            local ok, asset = pcall(assetLoader, path)
            if ok and asset then return asset end
        end
    end
    return nil
end

local tabIcons = {}
for name, url in pairs(tabIconUrls) do
    tabIcons[name] = loadIcon(name, url)
end
getgenv().TabIcons = tabIcons
getgenv().TabIconUrls = tabIconUrls

if not getgenv().SliderFillBound then
    getgenv().SliderFillBound = true
    RunService.RenderStepped:Connect(function(dt)
        local stateMap = getgenv().SliderFillState
        if not stateMap then return end
        dt = math.clamp(tonumber(dt) or 0, 1 / 1000, 1 / 15)
        local follow = getgenv().SliderFollowRate or 11
        local step = 1 - math.exp(-follow * dt)
        for fill, st in pairs(stateMap) do
            if not fill.Parent then
                stateMap[fill] = nil
            else
                st.pos = st.pos + (st.target - st.pos) * step
                if math.abs(st.target - st.pos) < 0.35 then st.pos = st.target end
                local x = math.floor(st.pos + 0.5)
                fill.Size = UDim2.new(0, x, 1, 0)
                if st.hideBorder and st.sliderObj then
                    st.hideBorder.Visible = not (x == st.sliderObj.MaxSize or x == 0)
                end
            end
        end
    end)
end

local _griefGca = getcustomasset
if type(_griefGca) == "function" then getcustomasset = function(p) local ok, r = pcall(_griefGca, p) if ok then return r end return nil end end
local ObsidianRepo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/"
loadstring(game:HttpGet(ObsidianRepo .. "Library.lua"))()
Library = getgenv().Library or getgenv().ObsidianLibrary
getgenv().Library = Library
_G.Library = Library
GriefLib = Library
GriefFlags = {}
 
ThemeManager = loadstring(game:HttpGet(ObsidianRepo .. "addons/ThemeManager.lua"))()
SaveManager = loadstring(game:HttpGet(ObsidianRepo .. "addons/SaveManager.lua"))()
getgenv().ThemeManager = ThemeManager
getgenv().SaveManager = SaveManager
_G.ThemeManager = ThemeManager
_G.SaveManager = SaveManager
local QuartzTheme = { FontColor = "ffffff", MainColor = "232330", AccentColor = "426e87", BackgroundColor = "1d1b26", OutlineColor = "27232f", FontFace = "Code", BackgroundImage = "" }
pcall(function()
    ThemeManager:SetLibrary(Library)
    ThemeManager:SetDefaultTheme(QuartzTheme)
end)
GriefWindow = Library:CreateWindow({
    Title = "ghost Scripts | Rivals",
    Footer = "By @ghost.sceipts.01",
    Center = true,
    AutoShow = true,
    NotifySide = "Right",
    ShowCustomCursor = false,
})
Window = GriefWindow
getgenv().Window = Window
_G.Window = Window
getgenv().GriefWindow = GriefWindow
 
pcall(function()
    Window.Holder = Window.MainFrame or Window.Holder or { Visible = true }
end)
if typeof(isMenuOpen) ~= "function" then
    isMenuOpen = function() return Library and Library.Toggled == true end
    getgenv().isMenuOpen = isMenuOpen
end
if typeof(applyUiLayering) ~= "function" then
    applyUiLayering = function() end
    getgenv().applyUiLayering = applyUiLayering
end
if typeof(applyAccentTheme) ~= "function" then
    applyAccentTheme = function()
        pcall(function()
            if Library and Library.Scheme then
                Library.MainColor = Library.Scheme.MainColor
                Library.BackgroundColor = Library.Scheme.BackgroundColor
                Library.AccentColor = Library.Scheme.AccentColor
                Library.OutlineColor = Library.Scheme.OutlineColor
                Library.FontColor = Library.Scheme.FontColor
            end
        end)
    end
    getgenv().ApplyAccentTheme = applyAccentTheme
end
if typeof(getgenv().GetUiFont) ~= "function" then
    getgenv().GetUiFont = function() return Font.fromEnum(Enum.Font.Code) end
end
if typeof(getgenv().ApplyUiFont) ~= "function" then
    getgenv().ApplyUiFont = function(lbl, size)
        pcall(function()
            if lbl then
                lbl.FontFace = Font.fromEnum(Enum.Font.Code)
                if size then lbl.TextSize = size end
            end
        end)
    end
end
if _GAMEPLAY_OVERLAY_ORDER == nil then
    _GAMEPLAY_OVERLAY_ORDER = 10
    getgenv()._GAMEPLAY_OVERLAY_ORDER = 10
end
 
if typeof(shouldSuppressGameplayOverlays) ~= "function" then
    shouldSuppressGameplayOverlays = function() return false end
    getgenv().shouldSuppressGameplayOverlays = shouldSuppressGameplayOverlays
end
if typeof(markCombatShot) ~= "function" then
    markCombatShot = function() end
    getgenv().markCombatShot = markCombatShot
end
if typeof(worldToScreen) ~= "function" then
    worldToScreen = function(worldPos, cam)
        local c = cam or game:GetService("Workspace").CurrentCamera
        if not c or not worldPos then return Vector2.new(0, 0), false end
        local ok, v3, onScreen = pcall(function() return c:WorldToViewportPoint(worldPos) end)
        if not ok or not v3 then return Vector2.new(0, 0), false end
        return Vector2.new(v3.X, v3.Y), onScreen
    end
    getgenv().worldToScreen = worldToScreen
end
if typeof(screenCenter) ~= "function" then
    screenCenter = function(cam)
        local c = cam or game:GetService("Workspace").CurrentCamera
        if c then
            local ok, vs = pcall(function() return c.ViewportSize end)
            if ok and vs then return vs / 2 end
        end
        return Vector2.new(960, 540)
    end
    getgenv().screenCenter = screenCenter
end
if typeof(getgenv().TrackDrawingText) ~= "function" then
    getgenv().TrackDrawingText = function(obj) return obj end
end
if typeof(TrackDrawingText) ~= "function" then
    TrackDrawingText = getgenv().TrackDrawingText
end
if Camera == nil then
    pcall(function()
        Camera = game:GetService("Workspace").CurrentCamera
        getgenv().Camera = Camera
    end)
end
 
if typeof(getgenv().WorldToScreen) ~= "function" then
    getgenv().WorldToScreen = worldToScreen
end
if typeof(getgenv().WorldToScreenEsp) ~= "function" then
    getgenv().WorldToScreenEsp = getgenv().WorldToScreen
end
 
if type(Library.Create) ~= "function" then
    Library.Create = function(a, b, c)
        local className, props
        if type(a) == "string" or typeof(a) == "Instance" then
            className, props = a, b
        else
            className, props = b, c
        end
        local inst
        if typeof(className) == "Instance" then
            inst = className
        else
            inst = Instance.new(className)
        end
        if type(props) == "table" then
            for prop, value in pairs(props) do
                if value ~= nil then
                    pcall(function() inst[prop] = value end)
                end
            end
        end
        return inst
    end
end
if type(Library.CreateLabel) ~= "function" then
    Library.CreateLabel = function(a, b, _isHud)
        local props
        if type(b) == "table" then props = b
        elseif type(a) == "table" and type(a.Text) ~= nil then props = a
        else props = {} end
        local lbl = Library:Create("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.Code,
            TextColor3 = (Library.FontColor or Color3.new(1, 1, 1)),
            TextSize = 16,
        })
        if lbl and type(props) == "table" then Library:Create(lbl, props) end
        return lbl
    end
end
 
pcall(function()
    if Library and Library.Scheme then
        Library.MainColor = Library.Scheme.MainColor
        Library.BackgroundColor = Library.Scheme.BackgroundColor
        Library.AccentColor = Library.Scheme.AccentColor
        Library.OutlineColor = Library.Scheme.OutlineColor
        Library.FontColor = Library.Scheme.FontColor
    end
end)
if typeof(cloneref) ~= "function" then
    cloneref = function(x) return x end
    getgenv().cloneref = cloneref
end
Toggles = Library.Toggles
Options = Library.Options
_G.Toggles = Toggles
_G.Options = Options
getgenv().Toggles = Toggles
getgenv().Options = Options

-- ================================================================
--  CARREGAR MÓDULOS DO JOGO
-- ================================================================

local Utility = nil
local EnumLibrary = nil

task.spawn(function()
    pcall(function()
        local rs = game:GetService("ReplicatedStorage")
        local mods = rs:WaitForChild("Modules", 8)
        local um = mods:WaitForChild("Utility", 5)
        if um then
            local ok, mod = pcall(SafeRequire, um, 5)
            if ok and type(mod) == "table" then
                Utility = mod
                getgenv().Utility = mod
            end
        end
    end)
    pcall(function()
        local rs = game:GetService("ReplicatedStorage")
        local mods = rs:WaitForChild("Modules", 8)
        local em = mods:WaitForChild("EnumLibrary", 5)
        if em then
            local ok, mod = pcall(SafeRequire, em, 5)
            if ok and type(mod) == "table" then
                EnumLibrary = mod
                getgenv().EnumLibrary = mod
            end
        end
    end)
end)

-- ================================================================
--  CRIAÇÃO DAS ABAS
-- ================================================================

Tabs = {}
Tabs.Combat = Window:AddTab("Combat", "swords")
Tabs.Player = Window:AddTab("Player", "person-standing")
Tabs.Visuals = Window:AddTab("Visuals", "eye")
Tabs.FPS = Window:AddTab("FPS", "zap")
Tabs.Misc = Window:AddTab("Misc", "circle-ellipsis")
Tabs['UI Settings'] = Window:AddTab("UI Settings", "settings")
_G.Tabs = Tabs
getgenv().Tabs = Tabs

-- ================================================================
--  SETTINGS GLOBAIS
-- ================================================================

local GlobalSettings = {
    TeamCheck = false,
    WallCheck = true,
}

local AimbotSettings = {
	AimbotEnabled = false,
	Mode = "Legit",
	TargetLock = true,
	FOV = 150,
	Smoothness = 35,
	MaxDistance = 1000,
	ShowFOV = false,
	KeybindMode = "Toggle",
	HoldActive = false,
}

local SilentAimSettings = {
	Enabled = false,
	HitPart = "Head",
	FOV = 150,
	ShowFOV = false,
	AutoShoot = false,
	HitChance = 100,
	KeybindMode = "Toggle",
	HoldActive = false,
	MaxDistance = 1000,
}

local MovementSettings = {
    SpeedEnabled = false,
    SpeedValue = 30,
    NoclipEnabled = false,
    InfJumpEnabled = false,
    JumpPower = 50,
}

local FPSSettings = {
    SmoothTextures = false,
    DarkTextures = false,
    TransparentTextures = false,
    TransparencyValue = 0.6,
    DisableLighting = false,
    NoShadows = false,
    NoBloom = false,
    NoBlur = false,
    NoAtmosphere = false,
    NoSkybox = false,
    NoParticles = false,
    NoDecals = false,
    NoTextures = false,
    NoGrass = false,
    NoFog = false,
}

local _noclipConn = nil
local _speedConn = nil
local _jumpConn = nil

local CurrentTarget = nil
local CurrentPart = nil

-- ================================================================
--  TEAM CHECK V2.0
-- ================================================================

local TeamCheckConfig = {
	CacheTimeout = 0.5,
	UseCache = true,
}
local teamCache = { playerData = {} }

local function GetFromCache(targetPlayer)
	if not TeamCheckConfig.UseCache then return nil end
	local cached = teamCache.playerData[targetPlayer.UserId]
	if cached and cached.timestamp > tick() - TeamCheckConfig.CacheTimeout then
		return cached.isAlly
	end
	return nil
end

local function SaveToCache(targetPlayer, isAllyResult)
	if not TeamCheckConfig.UseCache then return end
	teamCache.playerData[targetPlayer.UserId] = {
		isAlly = isAllyResult,
		timestamp = tick()
	}
end

local function isAlly(targetPlayer)
	if not targetPlayer then return false end
	if targetPlayer == LocalPlayer then return true end
	if not targetPlayer.Parent then return false end

	local cachedResult = GetFromCache(targetPlayer)
	if cachedResult ~= nil then return cachedResult end

	local result = false
	if targetPlayer.Team and LocalPlayer.Team and targetPlayer.Team == LocalPlayer.Team then result = true end
	if not result then
		local myTeamID = LocalPlayer:GetAttribute("TeamID")
		local theirTeamID = targetPlayer:GetAttribute("TeamID")
		if myTeamID and theirTeamID and myTeamID == theirTeamID then result = true end
	end
	if not result then
		local myColor = LocalPlayer:GetAttribute("TeamColor")
		local theirColor = targetPlayer:GetAttribute("TeamColor")
		if myColor and theirColor and myColor == theirColor then result = true end
	end
	if not result then
		local myFaction = LocalPlayer:GetAttribute("Faction")
		local theirFaction = targetPlayer:GetAttribute("Faction")
		if myFaction and theirFaction and myFaction == theirFaction then result = true end
	end
	if not result then
		local myAlly = LocalPlayer:GetAttribute("Ally")
		local theirAlly = targetPlayer:GetAttribute("Ally")
		if myAlly and theirAlly and myAlly == theirAlly then result = true end
	end

	SaveToCache(targetPlayer, result)
	return result
end

local function isEnemy(targetPlayer)
	if not targetPlayer then return false end
	if targetPlayer == LocalPlayer then return false end
	return not isAlly(targetPlayer)
end

local function isSameTeam(plr)
	if not GlobalSettings.TeamCheck then return false end
	return isAlly(plr)
end

local COLOR_VISIBLE = Color3.fromRGB(0, 255, 100)
local COLOR_BLOCKED = Color3.fromRGB(255, 60, 60)

local function isAlive(char)
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	return hum and hum.Health > 0
end

local function isPositionVisible(pos)
	local cam = workspace.CurrentCamera
	if not cam then return true end
	local origin = cam.CFrame.Position
	local dir = pos - origin
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {LocalPlayer.Character}
	params.FilterType = Enum.RaycastFilterType.Exclude
	local result = workspace:Raycast(origin, dir, params)
	if not result then return true end
	return (result.Position - pos).Magnitude < 3
end

-- ================================================================
--  AIMBOT CORE
-- ================================================================

local function getBestTarget()
	local cam = workspace.CurrentCamera
	if not cam then return nil, false end
	local best, bestDot = nil, -1
	local bestVisible = false
	local screenCenter = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
	local aimPartName = (AimbotSettings.Mode == "Rage") and "Head" or "UpperTorso"

	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and not isSameTeam(plr) then
			local part = plr.Character:FindFirstChild(aimPartName)
				or plr.Character:FindFirstChild("Head")
				or plr.Character:FindFirstChild("HumanoidRootPart")

			if part and isAlive(plr.Character) then
				local dist = (part.Position - cam.CFrame.Position).Magnitude
				if dist <= AimbotSettings.MaxDistance then
					local screenPos, onScreen = cam:WorldToViewportPoint(part.Position)
					if onScreen then
						local screenVec = Vector2.new(screenPos.X, screenPos.Y)
						local distFromCenter = (screenVec - screenCenter).Magnitude
						if distFromCenter <= AimbotSettings.FOV then
							local dir = (part.Position - cam.CFrame.Position).Unit
							local dot = cam.CFrame.LookVector:Dot(dir)
							if dot > bestDot then
								bestDot = dot
								best = part
								bestVisible = isPositionVisible(part.Position)
							end
						end
					end
				end
			end
		end
	end
	if best and GlobalSettings.WallCheck and not bestVisible then
		return nil, false
	end
	return best, bestVisible
end

-- ================================================================
--  FOV CIRCLES
-- ================================================================

local FOVCircleGui = Instance.new("ScreenGui")
FOVCircleGui.Name = "FOV_Circle"
FOVCircleGui.ResetOnSpawn = false
FOVCircleGui.IgnoreGuiInset = true
FOVCircleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
FOVCircleGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOV"
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.fromScale(0.5, 0.5)
FOVCircle.Size = UDim2.fromOffset(AimbotSettings.FOV * 2, AimbotSettings.FOV * 2)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = false
FOVCircle.Parent = FOVCircleGui
Instance.new("UICorner", FOVCircle).CornerRadius = UDim.new(1, 0)

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = COLOR_BLOCKED
FOVStroke.Transparency = 0.35
FOVStroke.Thickness = 2.5
FOVStroke.Parent = FOVCircle

local SilentFOVCircle = Instance.new("Frame")
SilentFOVCircle.Name = "SilentFOV"
SilentFOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
SilentFOVCircle.Position = UDim2.fromScale(0.5, 0.5)
SilentFOVCircle.Size = UDim2.fromOffset(SilentAimSettings.FOV * 2, SilentAimSettings.FOV * 2)
SilentFOVCircle.BackgroundTransparency = 1
SilentFOVCircle.Visible = false
SilentFOVCircle.Parent = FOVCircleGui
Instance.new("UICorner", SilentFOVCircle).CornerRadius = UDim.new(1, 0)

local SilentFOVStroke = Instance.new("UIStroke")
SilentFOVStroke.Color = Color3.fromRGB(255, 255, 255)
SilentFOVStroke.Transparency = 0.35
SilentFOVStroke.Thickness = 2
SilentFOVStroke.Parent = SilentFOVCircle

-- ================================================================
--  AIM LOOP
-- ================================================================

RunService:BindToRenderStep(
	"GhostAimbotLoop",
	Enum.RenderPriority.Camera.Value + 1,
	function(DeltaTime)
		local Cam = workspace.CurrentCamera
		if not Cam then return end

		FOVCircle.Visible = AimbotSettings.ShowFOV
		if AimbotSettings.ShowFOV then
			FOVCircle.Size = UDim2.fromOffset(AimbotSettings.FOV * 2, AimbotSettings.FOV * 2)
		end

		SilentFOVCircle.Visible = SilentAimSettings.ShowFOV
		if SilentAimSettings.ShowFOV then
			SilentFOVCircle.Size = UDim2.fromOffset(SilentAimSettings.FOV * 2, SilentAimSettings.FOV * 2)
		end

		local active = AimbotSettings.AimbotEnabled
		if AimbotSettings.KeybindMode == "Hold" then
			active = AimbotSettings.HoldActive
		end
		if not active then
			CurrentTarget = nil
			CurrentPart = nil
			if not SilentAimSettings.Enabled then
				FOVStroke.Color = COLOR_BLOCKED
			end
			return
		end

		local target, isVisible = getBestTarget()
		if target then
			CurrentPart = target

			if isVisible then
				FOVStroke.Color = COLOR_VISIBLE
			else
				FOVStroke.Color = COLOR_BLOCKED
			end

			if AimbotSettings.Mode == "Rage" then
				Cam.CFrame = CFrame.new(Cam.CFrame.Position, target.Position)
			else
				local Desired = CFrame.new(Cam.CFrame.Position, target.Position)
				local Speed = 1 + (AimbotSettings.Smoothness / 100) * 6
				local Alpha = 1 - math.exp(-Speed * DeltaTime)
				Cam.CFrame = Cam.CFrame:Lerp(Desired, Alpha)
			end
		else
			CurrentPart = nil
			FOVStroke.Color = COLOR_BLOCKED
		end
	end
)

getgenv().AimbotSystem = {
	Settings = AimbotSettings,
	Global = GlobalSettings,
	GetTarget = function() return CurrentPart end,
	IsAlly = isAlly,
	IsEnemy = isEnemy,
	FOVCircle = FOVCircle,
	FOVStroke = FOVStroke,
}

-- ================================================================
--  SILENT AIM SYSTEM-- ================================================================

local function curweap()
	local vm = workspace:FindFirstChild("ViewModels")
	if not vm then return nil end
	local fp = vm:FindFirstChild("FirstPerson")
	if not fp then return nil end
	for _, child in ipairs(fp:GetChildren()) do
		local parts = {}
		for part in child.Name:gmatch("[^-]+") do
			table.insert(parts, part:match("^%s*(.-)%s*$"))
		end
		if #parts >= 2 then return parts[2] end
	end
	return nil
end

local function getSilentTarget()
	local cam = workspace.CurrentCamera
	if not cam then return nil end
	local best, bestDist = nil, SilentAimSettings.FOV
	local screenCenter = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)

	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and not isSameTeam(plr) then
			local part = plr.Character:FindFirstChild(SilentAimSettings.HitPart)
				or plr.Character:FindFirstChild("Head")
				or plr.Character:FindFirstChild("HumanoidRootPart")

			if part and isAlive(plr.Character) then
				local dist = (part.Position - cam.CFrame.Position).Magnitude
				if dist <= SilentAimSettings.MaxDistance then
					local screenPos, onScreen = cam:WorldToViewportPoint(part.Position)
					if onScreen then
						local screenVec = Vector2.new(screenPos.X, screenPos.Y)
						local distFromCenter = (screenVec - screenCenter).Magnitude
						if distFromCenter <= bestDist then
							if GlobalSettings.WallCheck and not isPositionVisible(part.Position) then
								-- pula
							else
								best = part
								bestDist = distFromCenter
							end
						end
					end
				end
			end
		end
	end
	return best
end

local lastSilentFire = 0
local silentFireCooldown = 0.05
local lastSilentShotAt = 0

local function shouldSilentHit()
	if SilentAimSettings.HitChance >= 100 then return true end
	if SilentAimSettings.HitChance <= 0 then return false end
	return math.random(1, 100) <= SilentAimSettings.HitChance
end

local function firesilent()
	if not SilentAimSettings.Enabled then return end
	local weapon = curweap()
	if not weapon then return end

	local now = tick()
	if now - lastSilentFire < silentFireCooldown then return end
	if not shouldSilentHit() then return end

	local targetPart = getSilentTarget()
	if not targetPart then return end

	local lf = nil
	pcall(function()
		local fc = SafeRequire(LocalPlayer.PlayerScripts.Controllers.FighterController, 3)
		if fc then lf = fc.LocalFighter end
	end)
	if not lf or not lf.EquippedItem then return end

	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local equipped = lf.EquippedItem
	local objId = equipped:Get("ObjectID")
	if not objId then return end

	if not Utility or not Utility.EncodeCFrame then return end
	if not EnumLibrary or not EnumLibrary.ToEnum then return end

	lastSilentFire = now
	lastSilentShotAt = tick()

	local shootPos = root.Position
	local targetPos = targetPart.Position

	local data = {
		[utf8.char(1)] = {
			[utf8.char(0)] = Utility:EncodeCFrame(CFrame.new(shootPos, targetPos)),
			[utf8.char(1)] = Utility:EncodeCFrame(CFrame.new(shootPos, targetPos)),
			[utf8.char(2)] = targetPart,
			[utf8.char(3)] = Utility:EncodeCFrame(CFrame.new(0.43, 0.25, 0.42)),
		},
	}

	pcall(function()
		ReplicatedStorage.Remotes.Replication.Fighter.UseItem:FireServer(
			objId,
			EnumLibrary:ToEnum("StartShooting"),
			data,
			nil
		)
	end)
end

RunService.Heartbeat:Connect(function()
	if not SilentAimSettings.Enabled then return end
	local active = SilentAimSettings.Enabled
	if SilentAimSettings.KeybindMode == "Hold" then
		active = SilentAimSettings.HoldActive
	end
	if not active then return end

	local shouldFire = SilentAimSettings.AutoShoot
		or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)

	if shouldFire then
		firesilent()
	end
end)

RunService.RenderStepped:Connect(function()
	if not SilentAimSettings.ShowFOV then
		SilentFOVStroke.Color = Color3.fromRGB(255, 255, 255)
		return
	end
	local targetPart = getSilentTarget()
	if targetPart then
		SilentFOVStroke.Color = COLOR_VISIBLE
	else
		SilentFOVStroke.Color = Color3.fromRGB(255, 255, 255)
	end
end)

getgenv().SilentAimSystem = {
	Settings = SilentAimSettings,
	Global = GlobalSettings,
	GetTarget = getSilentTarget,
	ForceFire = firesilent,
}

-- ================================================================
--  MOVEMENT SYSTEM
-- ================================================================

local function updateNoclip()
    if _noclipConn then
        _noclipConn:Disconnect()
        _noclipConn = nil
    end
    local char = LocalPlayer.Character
    if not char then return end

    if MovementSettings.NoclipEnabled then
        _noclipConn = RunService.Stepped:Connect(function()
            local c = LocalPlayer.Character
            if not c then return end
            for _, part in ipairs(c:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    else
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

local function updateSpeed()
    if _speedConn then
        _speedConn:Disconnect()
        _speedConn = nil
    end
    if not MovementSettings.SpeedEnabled then return end

    _speedConn = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end

        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            local targetVel = moveDir * MovementSettings.SpeedValue
            hrp.AssemblyLinearVelocity = Vector3.new(
                targetVel.X,
                hrp.AssemblyLinearVelocity.Y,
                targetVel.Z
            )
        end
    end)
end

local function updateJump()
    if _jumpConn then
        _jumpConn:Disconnect()
        _jumpConn = nil
    end
    if not MovementSettings.InfJumpEnabled then return end

    _jumpConn = UserInputService.JumpRequest:Connect(function()
        if not MovementSettings.InfJumpEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

RunService.Heartbeat:Connect(function()
    if MovementSettings.JumpPower and MovementSettings.JumpPower > 50 then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.UseJumpPower = true
                hum.JumpPower = MovementSettings.JumpPower
            end
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if MovementSettings.NoclipEnabled then updateNoclip() end
end)

getgenv().CleanupMovement = function()
    if _noclipConn then _noclipConn:Disconnect() _noclipConn = nil end
    if _speedConn then _speedConn:Disconnect() _speedConn = nil end
    if _jumpConn then _jumpConn:Disconnect() _jumpConn = nil end
end

getgenv().MovementSystem = {
    Settings = MovementSettings,
    UpdateNoclip = updateNoclip,
    UpdateSpeed = updateSpeed,
    UpdateJump = updateJump,
}

-- ================================================================
--  FPS BOOST SYSTEM
-- ================================================================

local _origData = {
    lighting = {},
    parts = {},
}

local _fpsConns = {}

local function trackOrig(inst, prop, value)
    if not _origData.parts[inst] then
        _origData.parts[inst] = {}
    end
    if _origData.parts[inst][prop] == nil then
        _origData.parts[inst][prop] = value
    end
end

local function applySmoothTexture(part)
    if not part:IsA("BasePart") then return end
    pcall(function()
        trackOrig(part, "Material", part.Material)
        trackOrig(part, "Color", part.Color)
        part.Material = Enum.Material.SmoothPlastic
        part.Color = Color3.new(0.75, 0.75, 0.75)
    end)
end

local function applyDarkTexture(part)
    if not part:IsA("BasePart") then return end
    pcall(function()
        trackOrig(part, "Color", part.Color)
        local c = part.Color
        part.Color = Color3.new(c.R * 0.45, c.G * 0.45, c.B * 0.45)
    end)
end

local function applyTransparentTexture(part)
    if not part:IsA("BasePart") then return end
    local model = part:FindFirstAncestorWhichIsA("Model")
    if model then
        if Players:GetPlayerFromCharacter(model) then return end
        if model:FindFirstChildOfClass("Humanoid") then return end
    end
    pcall(function()
        trackOrig(part, "Transparency", part.Transparency)
        part.Transparency = math.clamp(FPSSettings.TransparencyValue, 0, 1)
    end)
end

local function storeLighting()
    local L = game:GetService("Lighting")
    _origData.lighting.GlobalShadows = L.GlobalShadows
    _origData.lighting.FogEnd = L.FogEnd
    _origData.lighting.FogStart = L.FogStart
    _origData.lighting.Brightness = L.Brightness
    _origData.lighting.ClockTime = L.ClockTime
    _origData.lighting.Ambient = L.Ambient
    _origData.lighting.OutdoorAmbient = L.OutdoorAmbient
end

local function scanParts()
    for _, inst in ipairs(workspace:GetDescendants()) do
        if inst:IsA("BasePart") then
            if FPSSettings.SmoothTextures then applySmoothTexture(inst) end
            if FPSSettings.DarkTextures then applyDarkTexture(inst) end
            if FPSSettings.TransparentTextures then applyTransparentTexture(inst) end
        end
    end
end

local function restoreAllParts()
    for inst, props in pairs(_origData.parts) do
        if inst and inst.Parent then
            for prop, value in pairs(props) do
                pcall(function() inst[prop] = value end)
            end
        end
    end
    table.clear(_origData.parts)
end

local function applyLighting()
    local L = game:GetService("Lighting")
    if FPSSettings.NoShadows then L.GlobalShadows = false end
    if FPSSettings.NoFog then
        L.FogEnd = math.huge
        L.FogStart = math.huge
    end
    if FPSSettings.NoBloom then
        for _, fx in ipairs(L:GetChildren()) do
            if fx:IsA("BloomEffect") then fx.Enabled = false end
        end
    end
    if FPSSettings.NoBlur then
        for _, fx in ipairs(L:GetChildren()) do
            if fx:IsA("BlurEffect") then fx.Enabled = false end
        end
    end
    if FPSSettings.NoAtmosphere then
        for _, fx in ipairs(L:GetChildren()) do
            if fx:IsA("Atmosphere") then fx.Density = 0 end
        end
    end
    if FPSSettings.DisableLighting then
        for _, fx in ipairs(L:GetChildren()) do
            if fx:IsA("PostEffect") or fx:IsA("Atmosphere") then
                fx.Enabled = false
            end
        end
    end
    if FPSSettings.NoTextures or FPSSettings.NoDecals then
        for _, inst in ipairs(workspace:GetDescendants()) do
            if FPSSettings.NoTextures and (inst:IsA("Texture") or inst:IsA("SurfaceAppearance")) then
                pcall(function() inst.Transparency = 1 end)
            end
            if FPSSettings.NoDecals and inst:IsA("Decal") then
                pcall(function() inst.Transparency = 1 end)
            end
        end
    end
    if FPSSettings.NoGrass then
        pcall(function() workspace.Terrain.GrassLength = 0 end)
    end
    if FPSSettings.NoSkybox then
        local sky = L:FindFirstChildOfClass("Sky")
        if sky then
            _origData.lighting.sky = sky
            sky:Destroy()
        end
    end
    if FPSSettings.NoParticles then
        for _, inst in ipairs(workspace:GetDescendants()) do
            if inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Beam") then
                pcall(function() inst.Enabled = false end)
            end
        end
    end
end

local function restoreLighting()
    local L = game:GetService("Lighting")
    if _origData.lighting.GlobalShadows ~= nil then
        L.GlobalShadows = _origData.lighting.GlobalShadows
    end
    if _origData.lighting.FogEnd then
        L.FogEnd = _origData.lighting.FogEnd
        L.FogStart = _origData.lighting.FogStart
    end
    if _origData.lighting.sky and not L:FindFirstChildOfClass("Sky") then
        local sky = _origData.lighting.sky:Clone()
        sky.Parent = L
        _origData.lighting.sky = nil
    end
    for _, fx in ipairs(L:GetChildren()) do
        if fx:IsA("PostEffect") or fx:IsA("Atmosphere") then
            fx.Enabled = true
        end
    end
    pcall(function() workspace.Terrain.GrassLength = 0.5 end)
    for _, inst in ipairs(workspace:GetDescendants()) do
        if inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Beam") then
            pcall(function() inst.Enabled = true end)
        end
        if inst:IsA("Decal") or inst:IsA("Texture") or inst:IsA("SurfaceAppearance") then
            pcall(function() inst.Transparency = 0 end)
        end
    end
end

local function startFpsMaintenance()
    for _, conn in ipairs(_fpsConns) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(_fpsConns)

    table.insert(_fpsConns, workspace.DescendantAdded:Connect(function(inst)
        if not inst:IsA("BasePart") then return end
        task.defer(function()
            if FPSSettings.SmoothTextures then applySmoothTexture(inst) end
            if FPSSettings.DarkTextures then applyDarkTexture(inst) end
            if FPSSettings.TransparentTextures then applyTransparentTexture(inst) end
        end)
    end))

    table.insert(_fpsConns, RunService.Heartbeat:Connect(function()
        if FPSSettings.NoParticles then
            for _, inst in ipairs(workspace:GetDescendants()) do
                if (inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Beam")) and inst.Enabled then
                    inst.Enabled = false
                end
            end
        end
        if FPSSettings.NoTextures then
            for _, inst in ipairs(workspace:GetDescendants()) do
                if inst:IsA("Texture") or inst:IsA("SurfaceAppearance") then
                    inst.Transparency = 1
                end
            end
        end
    end))
end

getgenv().FPSSystem = {
    Settings = FPSSettings,
    Apply = function()
        storeLighting()
        scanParts()
        applyLighting()
        startFpsMaintenance()
    end,
    Restore = function()
        restoreAllParts()
        restoreLighting()
        for _, conn in ipairs(_fpsConns) do
            pcall(function() conn:Disconnect() end)
        end
        table.clear(_fpsConns)
    end,
    ClearAll = function()
        FPSSettings.SmoothTextures = false
        FPSSettings.DarkTextures = false
        FPSSettings.TransparentTextures = false
        FPSSettings.DisableLighting = false
        FPSSettings.NoShadows = false
        FPSSettings.NoBloom = false
        FPSSettings.NoBlur = false
        FPSSettings.NoAtmosphere = false
        FPSSettings.NoSkybox = false
        FPSSettings.NoParticles = false
        FPSSettings.NoDecals = false
        FPSSettings.NoTextures = false
        FPSSettings.NoGrass = false
        FPSSettings.NoFog = false
        getgenv().FPSSystem.Restore()
    end,
}

-- ================================================================
--  ESP SYSTEM
-- ================================================================

local ESPSettings = {
	ESP = false,
	ESP_Box3D = true,
	ESP_Name = true,
	ESP_Distance = true,
	ESP_Highlight = true,
	ESP_Arrow = true,
	ESP_Health = true,
	MaxDistance = 1000,
}

local HEALTH_GREEN = Color3.fromRGB(0, 255, 100)
local HEALTH_YELLOW = Color3.fromRGB(255, 220, 0)
local HEALTH_RED = Color3.fromRGB(255, 50, 50)

local ESP_LINE_THICKNESS = 3
local ESP_TEXT_SIZE = 15
local ESP_HIGHLIGHT_FILL = 0.7
local ESP_HIGHLIGHT_OUTLINE = 0

local ARROW_SIZE = 18
local ARROW_OFFSET = 15
local ARROW_MIN_RADIUS = 30
local HEALTH_RIGHT_OFFSET = 15

local nearEspDistance = 300
local nearEspUpdateInterval = 0.016666666666667
local farEspUpdateInterval = 0.033333333333333
local hiddenEspUpdateInterval = 0.05
local maxEspBundlesPerFrame = 4

local ESP_COLOR_VISIBLE = Color3.fromRGB(0, 255, 100)
local ESP_COLOR_BLOCKED = Color3.fromRGB(255, 60, 60)

local function isPositionVisibleESP(pos)
	if not GlobalSettings.WallCheck then return true end
	local cam = workspace.CurrentCamera
	if not cam then return true end
	local origin = cam.CFrame.Position
	local dir = pos - origin
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {LocalPlayer.Character}
	params.FilterType = Enum.RaycastFilterType.Exclude
	local result = workspace:Raycast(origin, dir, params)
	if not result then return true end
	return (result.Position - pos).Magnitude < 3
end

local drawingCapabilities = {
	medido = false, drawing = false, texto = false, triangle = false,
	filled = false, thickness = false, center = false, outline = false,
	outlineColor = false, font = false,
}

function drawingCapabilities.set(B, u, k)
	return pcall(function() B[u] = k end)
end

function drawingCapabilities.medir()
	if drawingCapabilities.medido then return drawingCapabilities end
	if Drawing == nil or type(Drawing.new) ~= "function" then return drawingCapabilities end
	local B, u = pcall(Drawing.new, "Square")
	if not B then return drawingCapabilities end
	drawingCapabilities.drawing = true
	drawingCapabilities.filled = drawingCapabilities.set(u, "Filled", false)
	drawingCapabilities.thickness = drawingCapabilities.set(u, "Thickness", 1)
	pcall(function() u:Remove() end)
	local k, T = pcall(Drawing.new, "Text")
	if k then
		drawingCapabilities.texto = true
		drawingCapabilities.center = drawingCapabilities.set(T, "Center", true)
		drawingCapabilities.outline = drawingCapabilities.set(T, "Outline", true)
		drawingCapabilities.outlineColor = drawingCapabilities.set(T, "OutlineColor", Color3.new())
		drawingCapabilities.font = drawingCapabilities.set(T, "Font", 2)
		pcall(function() T:Remove() end)
	end
	local W, l = pcall(Drawing.new, "Triangle")
	drawingCapabilities.triangle = W == true
	if W then pcall(function() l:Remove() end) end
	drawingCapabilities.medido = true
	return drawingCapabilities
end

function drawingCapabilities.ok()
	return (drawingCapabilities.medir()).drawing
end

local function createDrawingObject(B)
	if not drawingCapabilities.ok() then return nil end
	if B == "Triangle" and not drawingCapabilities.triangle then return nil end
	local u, k = pcall(function() return Drawing.new(B) end)
	if not u then return nil end
	drawingCapabilities.set(k, "Visible", false)
	drawingCapabilities.set(k, "Color", Color3.fromRGB(255, 255, 255))
	drawingCapabilities.set(k, "Transparency", 1)
	drawingCapabilities.set(k, "Thickness", ESP_LINE_THICKNESS)
	return k
end

local function createDrawingText(B)
	if not drawingCapabilities.ok() or not drawingCapabilities.texto then return nil end
	local u, k = pcall(function() return Drawing.new("Text") end)
	if not u then return nil end
	drawingCapabilities.set(k, "Visible", false)
	drawingCapabilities.set(k, "Color", B or Color3.fromRGB(255, 255, 255))
	drawingCapabilities.set(k, "Transparency", 1)
	drawingCapabilities.set(k, "Size", ESP_TEXT_SIZE)
	if drawingCapabilities.center then drawingCapabilities.set(k, "Center", true) end
	if drawingCapabilities.outline then drawingCapabilities.set(k, "Outline", true) end
	if drawingCapabilities.outlineColor then drawingCapabilities.set(k, "OutlineColor", Color3.fromRGB(0, 0, 0)) end
	if drawingCapabilities.font then drawingCapabilities.set(k, "Font", 2) end
	return k
end

local box3dEdges = {
	{1,2},{1,3},{1,5},{2,4},{2,6},{3,4},{3,7},{4,8},{5,6},{5,7},{6,8},{7,8},
}
local r15SkeletonLineCount = 14

local advanceUpdateDeadline = function(B, u, k)
	if B <= 0 or u - B > k then return u + k end
	return B + k
end

local featureBundles = {}

local createEspBundle = function(B)
	local u = {
		player = B,
		name = createDrawingText(Color3.fromRGB(255, 255, 255)),
		distance = createDrawingText(Color3.fromRGB(190, 200, 225)),
		health = createDrawingText(ESP_COLOR_VISIBLE),
		lines = {},
		arrow = createDrawingObject("Triangle"),
		box3dLines = {},
		highlight = nil,
		character = nil,
		humanoid = nil,
		root = nil,
		bodyParts = {},
		skeletonPairs = {},
		relationshipColor = ESP_COLOR_VISIBLE,
		relationshipLabel = "",
		nextVisualUpdate = 0,
	}
	if u.arrow and drawingCapabilities.filled then u.arrow.Filled = true end
	for B = 1, r15SkeletonLineCount, 1 do
		table.insert(u.lines, createDrawingObject("Line"))
	end
	featureBundles[B] = u
	return u
end

local hideEspDrawings = function(B)
	if B.name then B.name.Visible = false end
	if B.distance then B.distance.Visible = false end
	if B.health then B.health.Visible = false end
	if B.arrow then B.arrow.Visible = false end
	for _, u in ipairs(B.lines) do u.Visible = false end
	for _, u in ipairs(B.box3dLines) do u.Visible = false end
end

local hideEspBundle = function(B)
	hideEspDrawings(B)
	if B.highlight then B.highlight.Enabled = false end
end

local destroyEspBundle = function(B)
	if not B then return end
	local function rm(x) if x then pcall(function() x:Remove() end) end end
	rm(B.name); rm(B.distance); rm(B.health); rm(B.arrow)
	for _, k in ipairs(B.lines) do rm(k) end
	for _, k in ipairs(B.box3dLines) do rm(k) end
	if B.highlight then pcall(function() B.highlight:Destroy() end) end
end

local hideAllEspBundles = function()
	for _, b in pairs(featureBundles) do hideEspBundle(b) end
end

local worldToViewport = function(B, u)
	local k, T = B:WorldToViewportPoint(u)
	return Vector2.new(k.X, k.Y), T, k.Z
end

local ensureHighlight = function(B, u)
	local k = B.highlight
	local cam = workspace.CurrentCamera or workspace
	if not k or not k.Parent then
		local u, T = pcall(function()
			local h = Instance.new("Highlight")
			h.Name = "GhostESP_" .. tostring(B.player.UserId)
			h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			h.FillTransparency = ESP_HIGHLIGHT_FILL
			h.OutlineTransparency = ESP_HIGHLIGHT_OUTLINE
			h.Parent = cam
			return h
		end)
		if not u then return nil end
		k = T
		B.highlight = k
	elseif k.Parent ~= cam then
		k.Parent = cam
	end
	local color = B.relationshipColor or ESP_COLOR_VISIBLE
	k.Adornee = u
	k.FillColor = color
	k.OutlineColor = color
	return k
end

local ensureBox3dLines = function(B)
	if #B.box3dLines > 0 then return B.box3dLines end
	for _ = 1, #box3dEdges, 1 do
		local k = createDrawingObject("Line")
		if k then
			if drawingCapabilities.thickness then k.Thickness = ESP_LINE_THICKNESS end
			k.Color = B.relationshipColor or ESP_COLOR_VISIBLE
			table.insert(B.box3dLines, k)
		end
	end
	return B.box3dLines
end

local ensureArrow = function(B)
	if B.arrow then return B.arrow end
	B.arrow = createDrawingObject("Triangle")
	if B.arrow and drawingCapabilities.filled then
		B.arrow.Filled = true
	end
	return B.arrow
end

local renderArrowOnFOV = function(B, cam, targetScreenPos, depth)
	local tri = ensureArrow(B)
	if not tri then return end

	local viewport = cam.ViewportSize
	local center = Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)
	local dir = targetScreenPos - center

	if depth <= 0 then dir = -dir end
	if dir.Magnitude < 0.001 then dir = Vector2.new(0, -1) end

	local unit = dir.Unit
	local fovRadius = math.max(AimbotSettings.FOV, ARROW_MIN_RADIUS)
	local arrowCenter = center + unit * (fovRadius + ARROW_OFFSET)

	local tipDir = unit
	local tip = arrowCenter + tipDir * ARROW_SIZE
	local baseCenter = arrowCenter - tipDir * (ARROW_SIZE * 0.6)
	local perp = Vector2.new(-tipDir.Y, tipDir.X) * (ARROW_SIZE * 0.55)

	tri.PointA = tip
	tri.PointB = baseCenter + perp
	tri.PointC = baseCenter - perp
	tri.Color = B.relationshipColor or ESP_COLOR_VISIBLE
	tri.Visible = true
end

local refreshEspCharacter = function(B, u, k, T)
	if B.character == u and (B.humanoid == k and B.root == T) then return end
	B.character = u
	B.humanoid = k
	B.root = T
	table.clear(B.bodyParts)
	B.skeletonPairs = {}
	for _, part in ipairs(u:GetChildren()) do
		if part:IsA("BasePart") then
			table.insert(B.bodyParts, part)
		end
	end
end

local updateEspRelationshipStyle = function(B, u, isVisible)
	local color, label = "", ""
	if GlobalSettings.TeamCheck and isAlly(B) then
		color = Color3.fromRGB(60, 210, 255)
		label = " [TEAM]"
	else
		if GlobalSettings.WallCheck then
			color = isVisible and ESP_COLOR_VISIBLE or ESP_COLOR_BLOCKED
		else
			color = ESP_COLOR_VISIBLE
		end
	end

	u.relationshipLabel = label
	if u.relationshipColor == color then return end
	u.relationshipColor = color

	if u.name then u.name.Color = color end
	if u.distance then u.distance.Color = color end
	if u.arrow then u.arrow.Color = color end
	if u.highlight then
		u.highlight.FillColor = color
		u.highlight.OutlineColor = color
	end
	for _, line in ipairs(u.lines) do if line then line.Color = color end end
	for _, line in ipairs(u.box3dLines) do if line then line.Color = color end end
end

local renderPlayerEsp = function(B, u, k, T, W)
	local l = B.Character
	local I = l and l:FindFirstChildOfClass("Humanoid")
	local Y = l and l:FindFirstChild("HumanoidRootPart")
	if not l or not I or I.Health <= 0 or not Y then
		u.character = nil
		u.nextVisualUpdate = W + hiddenEspUpdateInterval
		hideEspBundle(u)
		return
	end
	refreshEspCharacter(u, l, I, Y)
	local q = (Y.Position - T).Magnitude
	if q > ESPSettings.MaxDistance then
		u.nextVisualUpdate = W + hiddenEspUpdateInterval
		hideEspBundle(u)
		return
	end

	local head = l:FindFirstChild("Head") or Y
	local isVisible = isPositionVisibleESP(head.Position)
	updateEspRelationshipStyle(B, u, isVisible)

	if ESPSettings.ESP_Highlight then
		local hl = ensureHighlight(u, l)
		if hl then hl.Enabled = true end
	elseif u.highlight then
		u.highlight.Enabled = false
	end

	local x, onScreen, z = worldToViewport(k, Y.Position)
	if not onScreen or z <= 0 then
		u.nextVisualUpdate = W + hiddenEspUpdateInterval
		hideEspDrawings(u)
		if ESPSettings.ESP_Arrow then
			renderArrowOnFOV(u, k, x, z)
		end
		return
	end

	if u.arrow then u.arrow.Visible = false end

	local E = q <= nearEspDistance
	local L = E and nearEspUpdateInterval or farEspUpdateInterval
	u.nextVisualUpdate = advanceUpdateDeadline(u.nextVisualUpdate, W, L)

	local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
	local X = false
	local screenCorners, depths = {}, {}
	local needBounds = ESPSettings.ESP_Box3D or ESPSettings.ESP_Name or ESPSettings.ESP_Distance or ESPSettings.ESP_Health
	if needBounds then
		local Bmin, Bmax
		for _, part in ipairs(u.bodyParts) do
			if part.Parent == l then
				local half = part.Size * 0.5
				local p1 = part.Position - half
				local p2 = part.Position + half
				if Bmin then
					Bmin = Vector3.new(math.min(Bmin.X, p1.X), math.min(Bmin.Y, p1.Y), math.min(Bmin.Z, p1.Z))
					Bmax = Vector3.new(math.max(Bmax.X, p2.X), math.max(Bmax.Y, p2.Y), math.max(Bmax.Z, p2.Z))
				else
					Bmin, Bmax = p1, p2
				end
			end
		end
		if Bmin then
			local idx = 0
			for xi = 0, 1 do
				for yi = 0, 1 do
					for zi = 0, 1 do
						idx = idx + 1
						local worldPos = Vector3.new(
							xi == 0 and Bmin.X or Bmax.X,
							yi == 0 and Bmin.Y or Bmax.Y,
							zi == 0 and Bmin.Z or Bmax.Z
						)
						local sp, onScr, dp = worldToViewport(k, worldPos)
						screenCorners[idx] = sp
						depths[idx] = dp
						if onScr and dp > 0.5 then
							X = true
							minX = math.min(minX, sp.X)
							minY = math.min(minY, sp.Y)
							maxX = math.max(maxX, sp.X)
							maxY = math.max(maxY, sp.Y)
						end
					end
				end
			end
		end
	end

	if ESPSettings.ESP_Box3D then
		local lines = ensureBox3dLines(u)
		for i, edge in ipairs(box3dEdges) do
			local line = lines[i]
			local c1 = screenCorners[edge[1]]
			local c2 = screenCorners[edge[2]]
			local d1 = depths[edge[1]]
			local d2 = depths[edge[2]]
			if line and c1 and c2 and d1 and d2 and d1 > 0.5 and d2 > 0.5 then
				line.From = c1
				line.To = c2
				line.Color = u.relationshipColor
				line.Visible = true
			elseif line then
				line.Visible = false
			end
		end
	else
		for _, l2 in ipairs(u.box3dLines) do l2.Visible = false end
	end

	if ESPSettings.ESP_Name and u.name then
		if X then
			u.name.Text = B.Name .. u.relationshipLabel
			u.name.Position = Vector2.new((minX + maxX) / 2, minY - 20)
			u.name.Color = u.relationshipColor
			u.name.Visible = true
		else
			u.name.Visible = false
		end
	elseif u.name then
		u.name.Visible = false
	end

	if ESPSettings.ESP_Distance and u.distance then
		if X then
			u.distance.Text = string.format("%dm", math.floor(q))
			u.distance.Position = Vector2.new((minX + maxX) / 2, maxY + 5)
			u.distance.Color = u.relationshipColor
			u.distance.Visible = true
		else
			u.distance.Visible = false
		end
	elseif u.distance then
		u.distance.Visible = false
	end

	if ESPSettings.ESP_Health and u.health then
		if X then
			local hp = math.floor(I.Health)
			local maxHp = math.floor(I.MaxHealth)
			u.health.Text = string.format("%d HP", hp)
			local ratio = hp / math.max(maxHp, 1)
			local hpColor
			if ratio > 0.6 then hpColor = HEALTH_GREEN
			elseif ratio > 0.3 then hpColor = HEALTH_YELLOW
			else hpColor = HEALTH_RED end
			u.health.Color = hpColor
			local midY = (minY + maxY) / 2
			u.health.Position = Vector2.new(maxX + HEALTH_RIGHT_OFFSET, midY)
			u.health.Visible = true
		else
			u.health.Visible = false
		end
	elseif u.health then
		u.health.Visible = false
	end
end

local espWasEnabled = false

Players.PlayerRemoving:Connect(function(B)
	local u = featureBundles[B]
	if u then
		destroyEspBundle(u)
		featureBundles[B] = nil
	end
end)

RunService.RenderStepped:Connect(function()
	if not ESPSettings.ESP then
		if espWasEnabled then hideAllEspBundles() end
		espWasEnabled = false
		return
	end
	espWasEnabled = true

	local cam = workspace.CurrentCamera
	if not cam then hideAllEspBundles(); return end
	local myChar = LocalPlayer.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	local origin = myRoot and myRoot.Position or cam.CFrame.Position
	local players = Players:GetPlayers()
	local now = os.clock()
	local budget = maxEspBundlesPerFrame

	for _, plr in ipairs(players) do
		if plr ~= LocalPlayer then
			if GlobalSettings.TeamCheck and isAlly(plr) then
				-- skip
			else
				local bundle = featureBundles[plr]
				if not bundle and budget > 0 then
					local ok, b = pcall(createEspBundle, plr)
					if ok then bundle = b end
					budget = budget - 1
				end
				if bundle and now >= bundle.nextVisualUpdate then
					pcall(renderPlayerEsp, plr, bundle, cam, origin, now)
				end
			end
		end
	end
end)

getgenv().ESPSystem = {
	Settings = ESPSettings,
	Global = GlobalSettings,
	Bundles = featureBundles,
}

-- ================================================================
--  UI - AIMBOT (Combat)
-- ================================================================

local aimbox = Tabs.Combat:AddLeftGroupbox("aimbot")

local aimToggle
aimToggle = aimbox:AddToggle("AimbotEnabled", {
	Text = "enable aimbot",
	Default = false,
	Callback = function(val)
		AimbotSettings.AimbotEnabled = val
		if not val then
			CurrentTarget = nil
			CurrentPart = nil
		end
	end,
}):AddKeyPicker("AimbotKeybind", {
	Text = "aimbot key",
	Default = "None",
	Mode = "Toggle",
	SyncToggleState = false,
	Modes = { "Toggle", "Hold" },
	Callback = function(state, mode)
		AimbotSettings.KeybindMode = mode or "Toggle"
		if AimbotSettings.KeybindMode == "Hold" then
			AimbotSettings.HoldActive = state
		else
			AimbotSettings.AimbotEnabled = state
			if aimToggle then
				pcall(function() aimToggle:SetValue(state) end)
			end
		end
	end,
})

aimbox:AddDropdown("AimbotMode", {
	Text = "mode",
	Default = "Legit",
	Values = { "Legit", "Rage" },
	Callback = function(val) AimbotSettings.Mode = val end,
})

aimbox:AddToggle("AimbotShowFOV", {
	Text = "show fov",
	Default = false,
	Callback = function(val)
		AimbotSettings.ShowFOV = val
		FOVCircle.Visible = val
	end,
})

aimbox:AddToggle("GlobalTeamCheck", {
	Text = "team check (global)",
	Default = false,
	Tooltip = "afeta aimbot + silent aim + esp",
	Callback = function(val) GlobalSettings.TeamCheck = val end,
})

aimbox:AddToggle("GlobalWallCheck", {
	Text = "wall check (global)",
	Default = true,
	Tooltip = "afeta aimbot + silent aim + esp",
	Callback = function(val) GlobalSettings.WallCheck = val end,
})

aimbox:AddToggle("AimbotTargetLock", {
	Text = "target lock",
	Default = true,
	Callback = function(val) AimbotSettings.TargetLock = val end,
})

aimbox:AddSlider("AimbotFOV", {
	Text = "fov",
	Default = 150,
	Min = 10,
	Max = 1000,
	Rounding = 0,
	Compact = true,
	Callback = function(val)
		AimbotSettings.FOV = val
		FOVCircle.Size = UDim2.fromOffset(val * 2, val * 2)
	end,
})

aimbox:AddSlider("AimbotSmoothness", {
	Text = "smoothness",
	Default = 35,
	Min = 1,
	Max = 100,
	Rounding = 0,
	Compact = true,
	Callback = function(val) AimbotSettings.Smoothness = val end,
})

aimbox:AddSlider("AimbotMaxDistance", {
	Text = "max distance",
	Default = 1000,
	Min = 100,
	Max = 5000,
	Rounding = 0,
	Compact = true,
	Callback = function(val) AimbotSettings.MaxDistance = val end,
})

-- ================================================================
--  UI - SILENT AIM (Combat)
-- ================================================================

local silentbox = Tabs.Combat:AddRightGroupbox("silent aim")

local silentToggle
silentToggle = silentbox:AddToggle("SilentAimEnabled", {
	Text = "enable silent aim",
	Default = false,
	Callback = function(val)
		SilentAimSettings.Enabled = val
	end,
}):AddKeyPicker("SilentAimKeybind", {
	Text = "silent aim key",
	Default = "None",
	Mode = "Toggle",
	SyncToggleState = false,
	Modes = { "Toggle", "Hold" },
	Callback = function(state, mode)
		SilentAimSettings.KeybindMode = mode or "Toggle"
		if SilentAimSettings.KeybindMode == "Hold" then
			SilentAimSettings.HoldActive = state
		else
			SilentAimSettings.Enabled = state
			if silentToggle then
				pcall(function() silentToggle:SetValue(state) end)
			end
		end
	end,
})

silentbox:AddDropdown("SilentHitPart", {
	Text = "hit part",
	Default = "Head",
	Values = { "Head", "HumanoidRootPart", "UpperTorso", "Torso", "LowerTorso" },
	Callback = function(val) SilentAimSettings.HitPart = val end,
})

silentbox:AddToggle("SilentShowFOV", {
	Text = "show fov",
	Default = false,
	Callback = function(val)
		SilentAimSettings.ShowFOV = val
		SilentFOVCircle.Visible = val
	end,
})

silentbox:AddToggle("SilentAutoShoot", {
	Text = "auto shoot",
	Default = false,
	Callback = function(val)
		SilentAimSettings.AutoShoot = val
	end,
})

silentbox:AddSlider("SilentFOV", {
	Text = "fov",
	Default = 150,
	Min = 10,
	Max = 1000,
	Rounding = 0,
	Compact = true,
	Callback = function(val)
		SilentAimSettings.FOV = val
		SilentFOVCircle.Size = UDim2.fromOffset(val * 2, val * 2)
	end,
})

silentbox:AddSlider("SilentMaxDistance", {
	Text = "max distance",
	Default = 1000,
	Min = 100,
	Max = 5000,
	Rounding = 0,
	Compact = true,
	Callback = function(val) SilentAimSettings.MaxDistance = val end,
})

silentbox:AddSlider("SilentHitChance", {
	Text = "hit chance",
	Default = 100,
	Min = 0,
	Max = 100,
	Rounding = 0,
	Suffix = "%",
	Compact = true,
	Callback = function(val) SilentAimSettings.HitChance = val end,
})

-- ================================================================
--  UI - MOVEMENT (Player)
-- ================================================================

local moveBox = Tabs.Player:AddLeftGroupbox("movement")

moveBox:AddToggle("NoclipEnabled", {
    Text = "noclip",
    Default = false,
    Callback = function(val)
        MovementSettings.NoclipEnabled = val
        updateNoclip()
    end,
})

moveBox:AddToggle("SpeedEnabled", {
    Text = "speed hack",
    Default = false,
    Callback = function(val)
        MovementSettings.SpeedEnabled = val
        updateSpeed()
    end,
})

moveBox:AddSlider("SpeedValue", {
    Text = "speed",
    Default = 30,
    Min = 16,
    Max = 500,
    Rounding = 0,
    Compact = true,
    Callback = function(val)
        MovementSettings.SpeedValue = val
    end,
})

moveBox:AddToggle("InfJumpEnabled", {
    Text = "infinite jump",
    Default = false,
    Callback = function(val)
        MovementSettings.InfJumpEnabled = val
        updateJump()
    end,
})

moveBox:AddSlider("JumpPower", {
    Text = "jump power",
    Default = 50,
    Min = 50,
    Max = 300,
    Rounding = 0,
    Compact = true,
    Callback = function(val)
        MovementSettings.JumpPower = val
    end,
})

-- ================================================================
--  UI - PLAYER INFO (Player)
-- ================================================================

local infoBox = Tabs.Player:AddRightGroupbox("player info")

infoBox:AddLabel("Nome: " .. LocalPlayer.Name)
infoBox:AddLabel("UserID: " .. tostring(LocalPlayer.UserId))
infoBox:AddLabel("Display: " .. LocalPlayer.DisplayName)

-- ================================================================
--  UI - ESP (Visuals)
-- ================================================================

local espbox = Tabs.Visuals:AddLeftGroupbox("esp")

espbox:AddToggle("ESP_Enabled", {
	Text = "enable esp",
	Default = false,
	Callback = function(val)
		ESPSettings.ESP = val
		if not val then hideAllEspBundles() end
	end,
})

espbox:AddToggle("ESP_Box3D", {
	Text = "3d box",
	Default = true,
	Callback = function(val) ESPSettings.ESP_Box3D = val end,
})

espbox:AddToggle("ESP_Name", {
	Text = "name",
	Default = true,
	Callback = function(val) ESPSettings.ESP_Name = val end,
})

espbox:AddToggle("ESP_Distance", {
	Text = "distance",
	Default = true,
	Callback = function(val) ESPSettings.ESP_Distance = val end,
})

espbox:AddToggle("ESP_Health", {
	Text = "health",
	Default = true,
	Callback = function(val) ESPSettings.ESP_Health = val end,
})

espbox:AddToggle("ESP_Highlight", {
	Text = "highlight",
	Default = true,
	Callback = function(val) ESPSettings.ESP_Highlight = val end,
})

espbox:AddToggle("ESP_Arrow", {
	Text = "offscreen arrow",
	Default = true,
	Callback = function(val) ESPSettings.ESP_Arrow = val end,
})

espbox:AddSlider("ESP_MaxDistance", {
	Text = "max distance",
	Default = 1000,
	Min = 100,
	Max = 5000,
	Rounding = 0,
	Compact = true,
	Callback = function(val) ESPSettings.MaxDistance = val end,
})

-- ================================================================
--  UI - FPS
-- ================================================================

local fpsBox = Tabs.FPS:AddLeftGroupbox("texture modifiers")

fpsBox:AddToggle("FPS_SmoothTextures", {
    Text = "smooth textures",
    Default = false,
    Tooltip = "substitui texturas por smooth plastic (FPS boost)",
    Callback = function(val)
        FPSSettings.SmoothTextures = val
        if val then getgenv().FPSSystem.Apply()
        else getgenv().FPSSystem.Restore() getgenv().FPSSystem.Apply() end
    end,
})

fpsBox:AddToggle("FPS_DarkTextures", {
    Text = "dark textures",
    Default = false,
    Tooltip = "escurece texturas do mundo",
    Callback = function(val)
        FPSSettings.DarkTextures = val
        if val then getgenv().FPSSystem.Apply()
        else getgenv().FPSSystem.Restore() getgenv().FPSSystem.Apply() end
    end,
})

fpsBox:AddToggle("FPS_TransparentTextures", {
    Text = "transparent textures",
    Default = false,
    Tooltip = "deixa o mundo semi-transparente",
    Callback = function(val)
        FPSSettings.TransparentTextures = val
        if val then getgenv().FPSSystem.Apply()
        else getgenv().FPSSystem.Restore() getgenv().FPSSystem.Apply() end
    end,
})

fpsBox:AddSlider("FPS_Transparency", {
    Text = "transparency",
    Default = 0.6,
    Min = 0.1,
    Max = 0.95,
    Rounding = 2,
    Compact = true,
    Callback = function(val)
        FPSSettings.TransparencyValue = val
        if FPSSettings.TransparentTextures then
            for inst, props in pairs(_origData.parts) do
                if inst and inst.Parent and props.Transparency ~= nil then
                    inst.Transparency = val
                end
            end
        end
    end,
})

fpsBox:AddToggle("FPS_NoTextures", {
    Text = "no surface textures",
    Default = false,
    Tooltip = "remove Texture / SurfaceAppearance",
    Callback = function(val)
        FPSSettings.NoTextures = val
        getgenv().FPSSystem.Apply()
    end,
})

fpsBox:AddToggle("FPS_NoDecals", {
    Text = "no decals",
    Default = false,
    Tooltip = "remove decals (logos/adesivos)",
    Callback = function(val)
        FPSSettings.NoDecals = val
        getgenv().FPSSystem.Apply()
    end,
})

fpsBox:AddToggle("FPS_NoParticles", {
    Text = "no particles",
    Default = false,
    Tooltip = "remove partículas / trails / beams",
    Callback = function(val)
        FPSSettings.NoParticles = val
        getgenv().FPSSystem.Apply()
    end,
})

local fpsRightBox = Tabs.FPS:AddRightGroupbox("effects")

fpsRightBox:AddToggle("FPS_NoShadows", {
    Text = "no shadows",
    Default = false,
    Callback = function(val)
        FPSSettings.NoShadows = val
        getgenv().FPSSystem.Apply()
    end,
})

fpsRightBox:AddToggle("FPS_DisableLighting", {
    Text = "disable lighting effects",
    Default = false,
    Tooltip = "remove bloom/blur/atmosphere/dof",
    Callback = function(val)
        FPSSettings.DisableLighting = val
        getgenv().FPSSystem.Apply()
    end,
})

fpsRightBox:AddToggle("FPS_NoBloom", {
    Text = "no bloom",
    Default = false,
    Callback = function(val)
        FPSSettings.NoBloom = val
        getgenv().FPSSystem.Apply()
    end,
})

fpsRightBox:AddToggle("FPS_NoBlur", {
    Text = "no blur",
    Default = false,
    Callback = function(val)
        FPSSettings.NoBlur = val
        getgenv().FPSSystem.Apply()
    end,
})

fpsRightBox:AddToggle("FPS_NoAtmosphere", {
    Text = "no atmosphere",
    Default = false,
    Callback = function(val)
        FPSSettings.NoAtmosphere = val
        getgenv().FPSSystem.Apply()
    end,
})

fpsRightBox:AddToggle("FPS_NoSkybox", {
    Text = "no skybox",
    Default = false,
    Callback = function(val)
        FPSSettings.NoSkybox = val
        getgenv().FPSSystem.Apply()
    end,
})

fpsRightBox:AddToggle("FPS_NoFog", {
    Text = "no fog",
    Default = false,
    Callback = function(val)
        FPSSettings.NoFog = val
        getgenv().FPSSystem.Apply()
    end,
})

fpsRightBox:AddToggle("FPS_NoGrass", {
    Text = "no terrain grass",
    Default = false,
    Callback = function(val)
        FPSSettings.NoGrass = val
        getgenv().FPSSystem.Apply()
    end,
})

fpsRightBox:AddButton({
    Text = "🎯 BOOST FPS (TUDO)",
    Func = function()
        FPSSettings.SmoothTextures = true
        FPSSettings.DarkTextures = true
        FPSSettings.NoShadows = true
        FPSSettings.DisableLighting = true
        FPSSettings.NoBloom = true
        FPSSettings.NoBlur = true
        FPSSettings.NoAtmosphere = true
        FPSSettings.NoSkybox = true
        FPSSettings.NoParticles = true
        FPSSettings.NoDecals = true
        FPSSettings.NoTextures = true
        FPSSettings.NoGrass = true
        FPSSettings.NoFog = true

        getgenv().FPSSystem.Apply()

        local toggles = {
            "FPS_SmoothTextures", "FPS_DarkTextures",
            "FPS_NoShadows", "FPS_DisableLighting",
            "FPS_NoBloom", "FPS_NoBlur", "FPS_NoAtmosphere",
            "FPS_NoSkybox", "FPS_NoParticles", "FPS_NoDecals",
            "FPS_NoTextures", "FPS_NoGrass", "FPS_NoFog",
        }
        for _, key in ipairs(toggles) do
            local opt = Options and Options[key]
            if opt then
                pcall(function() opt:SetValue(true) end)
            end
        end

        if Library and Library.Notify then
            Library:Notify({ Title = "FPS Boost", Description = "Todos os boosters ativados!", Time = 4 })
        end
    end,
})

fpsRightBox:AddButton({
    Text = "♻️ Restore Everything",
    Func = function()
        getgenv().FPSSystem.ClearAll()

        local keys = {
            "FPS_SmoothTextures", "FPS_DarkTextures", "FPS_TransparentTextures",
            "FPS_NoShadows", "FPS_DisableLighting", "FPS_NoBloom", "FPS_NoBlur",
            "FPS_NoAtmosphere", "FPS_NoSkybox", "FPS_NoParticles", "FPS_NoDecals",
            "FPS_NoTextures", "FPS_NoGrass", "FPS_NoFog",
        }
        for _, key in ipairs(keys) do
            local opt = Options and Options[key]
            if opt then
                pcall(function() opt:SetValue(false) end)
            end
        end

        if Library and Library.Notify then
            Library:Notify({ Title = "FPS Boost", Description = "Tudo restaurado!", Time = 4 })
        end
    end,
})

-- ================================================================
--  UI - CREDITS (Misc)
-- ================================================================

local creditsBox = Tabs.Misc:AddRightGroupbox("credits")

creditsBox:AddLabel("Criador: ghost Scripts")
creditsBox:AddLabel("Handle: @ghost.sceipts.01")
creditsBox:AddButton({
    Text = "📺 YouTube - ghost.scripts.01",
    Func = function()
        local url = "https://youtube.com/@ghost.scripts.01?si=y_ZReiiu1cuLc2O1"
        pcall(function()
            if setclipboard then setclipboard(url) end
        end)
        if Library and Library.Notify then
            Library:Notify({
                Title = "YouTube",
                Description = "Link copiado! Cole no navegador.",
                Time = 4,
            })
        end
        print("YouTube: " .. url)
    end,
})
creditsBox:AddLabel("youtube.com/@ghost.scripts.01")

-- ================================================================
--  UI - MENU SETTINGS
-- ================================================================

local uiTab = Tabs['UI Settings']
local menuBox = uiTab:AddRightGroupbox('menu settings')
menuBox:AddLabel('menu bind'):AddKeyPicker('MenuKeybind', {
	Default = 'RightShift',
	NoUI = true,
	Text = 'menu keybind'
})
Library.ToggleKeybind = Options.MenuKeybind

menuBox:AddButton('Unload Menu', function()
	Library:Unload()
end)

-- ================================================================
--  F4 QUICK TOGGLE
-- ================================================================

UserInputService.InputBegan:Connect(function(Input, Processed)
	if Processed then return end
	if Input.KeyCode == Enum.KeyCode.F4 then
		AimbotSettings.AimbotEnabled = not AimbotSettings.AimbotEnabled
		local opt = Options and Options.AimbotEnabled
		if opt then
			pcall(function() opt:SetValue(AimbotSettings.AimbotEnabled) end)
		end
		print("[Aimbot] " .. (AimbotSettings.AimbotEnabled and "ON" or "OFF"))
	end
end)

-- ================================================================
--  THEME / SAVE MANAGER
-- ================================================================

pcall(function()
    if ThemeManager and Library then
        ThemeManager:SetLibrary(Library)
        ThemeManager:SetFolder('ghost')
        ThemeManager:ApplyToTab(Tabs['UI Settings'])
        ThemeManager:ApplyTheme("Quartz")
    end
end)

pcall(function()
    if SaveManager and Library then
        SaveManager:SetLibrary(Library)
        if SaveManager.IgnoreThemeSettings then SaveManager:IgnoreThemeSettings() end
        if SaveManager.SetIgnoreIndexes then SaveManager:SetIgnoreIndexes({ "MenuKeybind" }) end
        SaveManager:SetFolder('ghost/rivals')
        SaveManager:BuildConfigSection(Tabs['UI Settings'])
        if SaveManager.LoadAutoloadConfig then SaveManager:LoadAutoloadConfig() end
    end
end)

pcall(function()
    if Library and Library.SetWatermark then
        Library:SetWatermark("ghost Scripts | @ghost.sceipts.01")
    end
end)

task.defer(function()
    task.wait(0.35)
    pcall(function()
        if typeof(applyAccentTheme) == "function" then applyAccentTheme() end
    end)
    task.wait(1.25)
    pcall(function()
        if typeof(applyAccentTheme) == "function" then applyAccentTheme() end
    end)
    getgenv().ConfigLoading = false
end)

print("[ghost Scripts] full suite loaded")
print("  - By @ghost.sceipts.01")
print("  - YouTube: https://youtube.com/@ghost.scripts.01")
print("  - Anti-cheat bypass: ON (soft)")
print("  - Obsidian panel: OK")
print("  - Combat: Aimbot + Silent Aim")
print("  - Player: Noclip / Speed / Inf Jump")
print("  - Visuals: ESP")
print("  - FPS: Texture + Effects boost")
print("  - Team + Wall Check: GLOBAIS")