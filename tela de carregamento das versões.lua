-- =======================================================
-- SCRIPT LOADER: ESTILO OBIDIGIAN (ORGANIZADO E SEM BUGS)
-- Apenas 1 script por vez, com trava de segurança
-- =======================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui") 
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- =======================================================
-- 🔒 TRAVAS GLOBAIS DE SEGURANÇA
-- =======================================================
local isLoading = false        -- Impede múltiplos loadings simultâneos
local isConfirmationOpen = false
local spinConnection = nil     -- Guarda a conexão do spinner para desconectar
local activeLoadingPanel = nil -- Guarda o painel atual

-- =======================================================
-- 🎨 PALETA DE CORES
-- =======================================================
local Theme = {
    Background = Color3.fromRGB(12, 12, 16),
    Secondary = Color3.fromRGB(20, 20, 26),
    Tertiary = Color3.fromRGB(28, 28, 36),
    Border = Color3.fromRGB(45, 45, 55),
    BorderPurple = Color3.fromRGB(75, 55, 100),
    TextPrimary = Color3.fromRGB(240, 240, 245),
    TextSecondary = Color3.fromRGB(140, 140, 150),
    Error = Color3.fromRGB(220, 50, 50),
}

local VersionColors = {
    BASICA = Color3.fromRGB(0, 170, 0),
    PADRAO = Color3.fromRGB(0, 100, 255),
    PRO = Color3.fromRGB(200, 0, 0),
}

-- =======================================================
-- 🔨 SISTEMA DE BANIMENTO
-- =======================================================
local BANNED_USERS = {
    -- "NomeDoJogador1",
    -- 123456789,
}

local isBanned = false
if player then
    for _, banned in ipairs(BANNED_USERS) do
        if type(banned) == "number" and player.UserId == banned then
            isBanned = true
            break
        elseif type(banned) == "string" and player.Name:lower() == banned:lower() then
            isBanned = true
            break
        end
    end
end

if isBanned then
    local BanGui = Instance.new("ScreenGui")
    BanGui.Name = "BanNotification"
    BanGui.ResetOnSpawn = false
    BanGui.Parent = CoreGui
    
    local BanFrame = Instance.new("Frame")
    BanFrame.Size = UDim2.new(0, 400, 0, 130)
    BanFrame.Position = UDim2.new(0.5, -200, 0.5, -65)
    BanFrame.BackgroundColor3 = Theme.Background
    BanFrame.BorderSizePixel = 0
    BanFrame.Parent = BanGui
    
    local BanCorner = Instance.new("UICorner")
    BanCorner.CornerRadius = UDim.new(0, 14)
    BanCorner.Parent = BanFrame
    
    local BanBorder = Instance.new("UIStroke")
    BanBorder.Color = Theme.Error
    BanBorder.Thickness = 1.5
    BanBorder.Transparency = 0.3
    BanBorder.Parent = BanFrame
    
    local BanText = Instance.new("TextLabel")
    BanText.Size = UDim2.new(1, -30, 0, 40)
    BanText.Position = UDim2.new(0, 15, 0, 25)
    BanText.BackgroundTransparency = 1
    BanText.Text = "ACESSO NEGADO"
    BanText.TextColor3 = Theme.TextPrimary
    BanText.TextScaled = true
    BanText.Font = Enum.Font.GothamBold
    BanText.TextXAlignment = Enum.TextXAlignment.Left
    BanText.Parent = BanFrame
    
    local BanSub = Instance.new("TextLabel")
    BanSub.Size = UDim2.new(1, -30, 0, 25)
    BanSub.Position = UDim2.new(0, 15, 0, 70)
    BanSub.BackgroundTransparency = 1
    BanSub.Text = "Você foi banido deste loader."
    BanSub.TextColor3 = Theme.TextSecondary
    BanSub.TextScaled = true
    BanSub.Font = Enum.Font.Gotham
    BanSub.TextXAlignment = Enum.TextXAlignment.Left
    BanSub.Parent = BanFrame
    
    task.wait(5)
    BanGui:Destroy()
    return
end

-- =======================================================
-- CRIANDO A INTERFACE PRINCIPAL
-- =======================================================

if CoreGui:FindFirstChild("RivalsLoaderGui") then
    CoreGui:FindFirstChild("RivalsLoaderGui"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RivalsLoaderGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui 

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 600, 0, 400) 
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.Active = false
MainFrame.Draggable = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainFrame

local MainBorder = Instance.new("UIStroke")
MainBorder.Color = Theme.BorderPurple
MainBorder.Thickness = 2
MainBorder.Transparency = 0
MainBorder.Parent = MainFrame

local MainBorderOuter = Instance.new("UIStroke")
MainBorderOuter.Color = Theme.BorderPurple:Lerp(Color3.new(1,1,1), 0.3)
MainBorderOuter.Thickness = 1
MainBorderOuter.Transparency = 0.7
MainBorderOuter.Parent = MainFrame

local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
Shadow.Size = UDim2.new(1, 40, 1, 40)
Shadow.ZIndex = -1
Shadow.Image = "rbxassetid://6014261993"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.5
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
Shadow.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -80, 0, 22)
TitleLabel.Position = UDim2.new(0, 22, 0, 12)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "ROBLOX RIVALS SCRIPT LOADER"
TitleLabel.TextColor3 = Theme.TextPrimary
TitleLabel.TextScaled = true
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = MainFrame

local SubtitleLabel = Instance.new("TextLabel")
SubtitleLabel.Size = UDim2.new(1, -80, 0, 16)
SubtitleLabel.Position = UDim2.new(0, 22, 0, 30)
SubtitleLabel.BackgroundTransparency = 1
SubtitleLabel.Text = "BY @ghost.scripts.01"
SubtitleLabel.TextColor3 = Theme.TextSecondary
SubtitleLabel.TextScaled = true
SubtitleLabel.Font = Enum.Font.GothamBold
SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
SubtitleLabel.Parent = MainFrame

-- =======================================================
-- 🔴 BOTÃO DE FECHAR (X)
-- =======================================================
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 32, 0, 32)
CloseButton.Position = UDim2.new(1, -44, 0, 10)
CloseButton.BackgroundColor3 = Theme.Tertiary
CloseButton.Text = "×"
CloseButton.TextColor3 = Theme.TextSecondary
CloseButton.TextScaled = true
CloseButton.Font = Enum.Font.GothamBold
CloseButton.ZIndex = 10
CloseButton.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

local CloseBorder = Instance.new("UIStroke")
CloseBorder.Color = Theme.Border
CloseBorder.Thickness = 1
CloseBorder.Transparency = 0.3
CloseBorder.Parent = CloseButton

CloseButton.MouseEnter:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Error, TextColor3 = Theme.TextPrimary}):Play()
end)
CloseButton.MouseLeave:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Tertiary, TextColor3 = Theme.TextSecondary}):Play()
end)

-- =======================================================
-- 🟢 BOTÃO FLUTUANTE PARA REABRIR
-- =======================================================
local ReopenButton = Instance.new("TextButton")
ReopenButton.Size = UDim2.new(0, 48, 0, 48)
ReopenButton.Position = UDim2.new(0, 20, 0.5, -24)
ReopenButton.BackgroundColor3 = Theme.Background
ReopenButton.Text = "≡"
ReopenButton.TextColor3 = Theme.TextPrimary
ReopenButton.TextScaled = true
ReopenButton.Font = Enum.Font.GothamBold
ReopenButton.Visible = false
ReopenButton.ZIndex = 15
ReopenButton.Parent = ScreenGui

local ReopenCorner = Instance.new("UICorner")
ReopenCorner.CornerRadius = UDim.new(0, 12)
ReopenCorner.Parent = ReopenButton

local ReopenBorder = Instance.new("UIStroke")
ReopenBorder.Color = Theme.BorderPurple
ReopenBorder.Thickness = 1.5
ReopenBorder.Transparency = 0
ReopenBorder.Parent = ReopenButton

ReopenButton.MouseEnter:Connect(function()
    TweenService:Create(ReopenButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Tertiary}):Play()
end)
ReopenButton.MouseLeave:Connect(function()
    TweenService:Create(ReopenButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Background}):Play()
end)

CloseButton.MouseButton1Click:Connect(function()
    -- 🔒 Se estiver carregando, bloqueia o fechamento
    if isLoading then return end
    ScreenGui.Enabled = false
    ReopenButton.Visible = true
end)

ReopenButton.MouseButton1Click:Connect(function()
    ReopenButton.Visible = false
    ScreenGui.Enabled = true
end)

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, -40, 0, 1)
Divider.Position = UDim2.new(0, 20, 0, 60)
Divider.BackgroundColor3 = Theme.BorderPurple
Divider.BackgroundTransparency = 0.5
Divider.BorderSizePixel = 0
Divider.Parent = MainFrame

-- =======================================================
-- ⚡ TELA DE CARREGAMENTO
-- =======================================================
local function showLoadingScreen(versionName, versionColor, callback)
    -- 🔒 Trava: não permite mais de um loading
    if isLoading then return end
    isLoading = true

    local LoadingPanel = Instance.new("Frame")
    LoadingPanel.Name = "LoadingPanel"
    LoadingPanel.Size = UDim2.new(0, 0, 0, 0)
    LoadingPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
    LoadingPanel.AnchorPoint = Vector2.new(0.5, 0.5)
    LoadingPanel.BackgroundColor3 = Theme.Background
    LoadingPanel.BorderSizePixel = 0
    LoadingPanel.ZIndex = 50
    LoadingPanel.Parent = ScreenGui
    activeLoadingPanel = LoadingPanel

    local PanelCorner = Instance.new("UICorner")
    PanelCorner.CornerRadius = UDim.new(0, 18)
    PanelCorner.Parent = LoadingPanel

    local PanelBorder = Instance.new("UIStroke")
    PanelBorder.Color = versionColor:Lerp(Color3.new(1,1,1), 0.5)
    PanelBorder.Thickness = 2
    PanelBorder.Transparency = 0.15
    PanelBorder.Parent = LoadingPanel

    local LoadingShadow = Instance.new("ImageLabel")
    LoadingShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    LoadingShadow.BackgroundTransparency = 1
    LoadingShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    LoadingShadow.Size = UDim2.new(1, 50, 1, 50)
    LoadingShadow.ZIndex = -1
    LoadingShadow.Image = "rbxassetid://6014261993"
    LoadingShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    LoadingShadow.ImageTransparency = 0.4
    LoadingShadow.ScaleType = Enum.ScaleType.Slice
    LoadingShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    LoadingShadow.Parent = LoadingPanel

    -- Spinner
    local SpinnerContainer = Instance.new("Frame")
    SpinnerContainer.Size = UDim2.new(0, 70, 0, 70)
    SpinnerContainer.Position = UDim2.new(0.5, -35, 0, 25)
    SpinnerContainer.BackgroundTransparency = 1
    SpinnerContainer.ZIndex = 51
    SpinnerContainer.Parent = LoadingPanel

    local SpinnerRing = Instance.new("Frame")
    SpinnerRing.Size = UDim2.new(1, 0, 1, 0)
    SpinnerRing.BackgroundTransparency = 1
    SpinnerRing.ZIndex = 51
    SpinnerRing.Parent = SpinnerContainer

    local SpinnerRingCorner = Instance.new("UICorner")
    SpinnerRingCorner.CornerRadius = UDim.new(1, 0)
    SpinnerRingCorner.Parent = SpinnerRing

    local RingStroke = Instance.new("UIStroke")
    RingStroke.Color = Theme.Tertiary
    RingStroke.Thickness = 4
    RingStroke.Transparency = 0.3
    RingStroke.Parent = SpinnerRing

    local Rotator = Instance.new("Frame")
    Rotator.Size = UDim2.new(1, 0, 1, 0)
    Rotator.BackgroundTransparency = 1
    Rotator.ZIndex = 52
    Rotator.Parent = SpinnerContainer

    local SpinnerDot = Instance.new("Frame")
    SpinnerDot.Size = UDim2.new(0, 14, 0, 14)
    SpinnerDot.Position = UDim2.new(0.5, -7, 0, -4)
    SpinnerDot.AnchorPoint = Vector2.new(0.5, 0.5)
    SpinnerDot.BackgroundColor3 = versionColor
    SpinnerDot.BorderSizePixel = 0
    SpinnerDot.ZIndex = 53
    SpinnerDot.Parent = Rotator

    local SpinnerDotCorner = Instance.new("UICorner")
    SpinnerDotCorner.CornerRadius = UDim.new(1, 0)
    SpinnerDotCorner.Parent = SpinnerDot

    local DotGlow = Instance.new("UIStroke")
    DotGlow.Color = versionColor:Lerp(Color3.new(1,1,1), 0.6)
    DotGlow.Thickness = 2
    DotGlow.Transparency = 0.4
    DotGlow.Parent = SpinnerDot

    -- 🔒 Desconecta conexão antiga antes de criar nova
    if spinConnection then
        spinConnection:Disconnect()
        spinConnection = nil
    end

    local rotation = 0
    spinConnection = RunService.RenderStepped:Connect(function(dt)
        if Rotator and Rotator.Parent then
            rotation = rotation + dt * 120
            if rotation >= 360 then rotation = rotation - 360 end
            Rotator.Rotation = rotation
        elseif spinConnection then
            spinConnection:Disconnect()
            spinConnection = nil
        end
    end)

    local LoadingText = Instance.new("TextLabel")
    LoadingText.Size = UDim2.new(1, -40, 0, 26)
    LoadingText.Position = UDim2.new(0, 20, 0, 110)
    LoadingText.BackgroundTransparency = 1
    LoadingText.Text = "Carregando " .. versionName
    LoadingText.TextColor3 = Theme.TextPrimary
    LoadingText.TextScaled = true
    LoadingText.Font = Enum.Font.GothamBold
    LoadingText.TextXAlignment = Enum.TextXAlignment.Center
    LoadingText.ZIndex = 51
    LoadingText.Parent = LoadingPanel

    local LoadingSub = Instance.new("TextLabel")
    LoadingSub.Size = UDim2.new(1, -40, 0, 16)
    LoadingSub.Position = UDim2.new(0, 20, 0, 140)
    LoadingSub.BackgroundTransparency = 1
    LoadingSub.Text = "Iniciando..."
    LoadingSub.TextColor3 = Theme.TextSecondary
    LoadingSub.TextScaled = true
    LoadingSub.Font = Enum.Font.Gotham
    LoadingSub.TextXAlignment = Enum.TextXAlignment.Center
    LoadingSub.ZIndex = 51
    LoadingSub.Parent = LoadingPanel

    local BarBackground = Instance.new("Frame")
    BarBackground.Size = UDim2.new(1, -60, 0, 10)
    BarBackground.Position = UDim2.new(0, 30, 0, 175)
    BarBackground.BackgroundColor3 = Theme.Tertiary
    BarBackground.BorderSizePixel = 0
    BarBackground.ZIndex = 51
    BarBackground.Parent = LoadingPanel

    local BarBgCorner = Instance.new("UICorner")
    BarBgCorner.CornerRadius = UDim.new(1, 0)
    BarBgCorner.Parent = BarBackground

    local BarFill = Instance.new("Frame")
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    BarFill.BackgroundColor3 = versionColor
    BarFill.BorderSizePixel = 0
    BarFill.ZIndex = 52
    BarFill.Parent = BarBackground

    local BarFillCorner = Instance.new("UICorner")
    BarFillCorner.CornerRadius = UDim.new(1, 0)
    BarFillCorner.Parent = BarFill

    local BarGlow = Instance.new("Frame")
    BarGlow.Size = UDim2.new(0, 30, 1, 0)
    BarGlow.Position = UDim2.new(1, -30, 0, 0)
    BarGlow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    BarGlow.BackgroundTransparency = 0.5
    BarGlow.BorderSizePixel = 0
    BarGlow.ZIndex = 53
    BarGlow.Parent = BarFill

    local PercentText = Instance.new("TextLabel")
    PercentText.Size = UDim2.new(1, -60, 0, 18)
    PercentText.Position = UDim2.new(0, 30, 0, 193)
    PercentText.BackgroundTransparency = 1
    PercentText.Text = "0%"
    PercentText.TextColor3 = Theme.TextSecondary
    PercentText.TextScaled = true
    PercentText.Font = Enum.Font.GothamBold
    PercentText.TextXAlignment = Enum.TextXAlignment.Right
    PercentText.ZIndex = 51
    PercentText.Parent = LoadingPanel

    LoadingPanel:TweenSize(
        UDim2.new(0, 460, 0, 240),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Back,
        0.4,
        true
    )

    local progress = 0
    local speed = 1.2
    
    local function animateProgress()
        while progress < 100 do
            progress = progress + speed
            if progress > 100 then progress = 100 end
            
            BarFill:TweenSize(
                UDim2.new(progress / 100, 0, 1, 0),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quad,
                0.15,
                true
            )
            PercentText.Text = math.floor(progress) .. "%"
            
            if progress < 30 then
                LoadingSub.Text = "Preparando ambiente..."
            elseif progress < 60 then
                LoadingSub.Text = "Baixando script..."
            elseif progress < 90 then
                LoadingSub.Text = "Executando código..."
            else
                LoadingSub.Text = "Finalizando..."
            end
            
            task.wait(0.05)
        end
        
        task.wait(0.5)
        
        LoadingPanel:TweenSize(
            UDim2.new(0, 0, 0, 0),
            Enum.EasingDirection.In,
            Enum.EasingStyle.Back,
            0.3,
            true
        )
        task.wait(0.35)
        
        -- 🔒 Limpa tudo com segurança
        if spinConnection then
            spinConnection:Disconnect()
            spinConnection = nil
        end
        if LoadingPanel and LoadingPanel.Parent then
            LoadingPanel:Destroy()
        end
        activeLoadingPanel = nil
        
        -- 🔒 Executa o callback (script)
        callback()
    end

    task.spawn(animateProgress)
end

-- =======================================================
-- 🌟 TELA DE CONFIRMAÇÃO
-- =======================================================
local function showConfirmation(versionName, versionColor, description, onConfirm)
    -- 🔒 Trava de segurança
    if isConfirmationOpen or isLoading then return end
    isConfirmationOpen = true

    local ConfirmPanel = Instance.new("Frame")
    ConfirmPanel.Name = "ConfirmPanel"
    ConfirmPanel.Size = UDim2.new(0, 0, 0, 0)
    ConfirmPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
    ConfirmPanel.AnchorPoint = Vector2.new(0.5, 0.5)
    ConfirmPanel.BackgroundColor3 = Theme.Background
    ConfirmPanel.BorderSizePixel = 0
    ConfirmPanel.ZIndex = 31
    ConfirmPanel.Parent = ScreenGui

    local ConfirmCorner = Instance.new("UICorner")
    ConfirmCorner.CornerRadius = UDim.new(0, 18)
    ConfirmCorner.Parent = ConfirmPanel

    local ConfirmBorder = Instance.new("UIStroke")
    ConfirmBorder.Color = versionColor:Lerp(Color3.new(1,1,1), 0.5)
    ConfirmBorder.Thickness = 2
    ConfirmBorder.Transparency = 0.15
    ConfirmBorder.Parent = ConfirmPanel

    local ConfirmShadow = Instance.new("ImageLabel")
    ConfirmShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    ConfirmShadow.BackgroundTransparency = 1
    ConfirmShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    ConfirmShadow.Size = UDim2.new(1, 50, 1, 50)
    ConfirmShadow.ZIndex = -1
    ConfirmShadow.Image = "rbxassetid://6014261993"
    ConfirmShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    ConfirmShadow.ImageTransparency = 0.4
    ConfirmShadow.ScaleType = Enum.ScaleType.Slice
    ConfirmShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    ConfirmShadow.Parent = ConfirmPanel

    local IconCircle = Instance.new("Frame")
    IconCircle.Size = UDim2.new(0, 56, 0, 56)
    IconCircle.Position = UDim2.new(0.5, -28, 0, 25)
    IconCircle.BackgroundColor3 = versionColor
    IconCircle.BorderSizePixel = 0
    IconCircle.ZIndex = 32
    IconCircle.Parent = ConfirmPanel

    local IconCircleCorner = Instance.new("UICorner")
    IconCircleCorner.CornerRadius = UDim.new(1, 0)
    IconCircleCorner.Parent = IconCircle

    local IconGlow = Instance.new("UIStroke")
    IconGlow.Color = versionColor:Lerp(Color3.new(1,1,1), 0.6)
    IconGlow.Thickness = 3
    IconGlow.Transparency = 0.3
    IconGlow.Parent = IconCircle

    local IconText = Instance.new("TextLabel")
    IconText.Size = UDim2.new(1, 0, 1, 0)
    IconText.BackgroundTransparency = 1
    IconText.Text = "?"
    IconText.TextColor3 = Color3.fromRGB(255, 255, 255)
    IconText.TextScaled = true
    IconText.Font = Enum.Font.GothamBold
    IconText.ZIndex = 33
    IconText.Parent = IconCircle

    local ConfirmTitle = Instance.new("TextLabel")
    ConfirmTitle.Size = UDim2.new(1, -40, 0, 24)
    ConfirmTitle.Position = UDim2.new(0, 20, 0, 95)
    ConfirmTitle.BackgroundTransparency = 1
    ConfirmTitle.Text = "Confirmar escolha"
    ConfirmTitle.TextColor3 = Theme.TextPrimary
    ConfirmTitle.TextScaled = true
    ConfirmTitle.Font = Enum.Font.GothamBold
    ConfirmTitle.TextXAlignment = Enum.TextXAlignment.Center
    ConfirmTitle.ZIndex = 32
    ConfirmTitle.Parent = ConfirmPanel

    local ConfirmSub = Instance.new("TextLabel")
    ConfirmSub.Size = UDim2.new(1, -40, 0, 18)
    ConfirmSub.Position = UDim2.new(0, 20, 0, 122)
    ConfirmSub.BackgroundTransparency = 1
    ConfirmSub.Text = "Tem certeza que deseja escolher essa versão?"
    ConfirmSub.TextColor3 = Theme.TextSecondary
    ConfirmSub.TextScaled = true
    ConfirmSub.Font = Enum.Font.Gotham
    ConfirmSub.TextXAlignment = Enum.TextXAlignment.Center
    ConfirmSub.ZIndex = 32
    ConfirmSub.Parent = ConfirmPanel

    local VersionLabel = Instance.new("TextLabel")
    VersionLabel.Size = UDim2.new(1, -40, 0, 26)
    VersionLabel.Position = UDim2.new(0, 20, 0, 148)
    VersionLabel.BackgroundTransparency = 1
    VersionLabel.Text = versionName
    VersionLabel.TextColor3 = versionColor:Lerp(Color3.new(1,1,1), 0.3)
    VersionLabel.TextScaled = true
    VersionLabel.Font = Enum.Font.GothamBold
    VersionLabel.TextXAlignment = Enum.TextXAlignment.Center
    VersionLabel.ZIndex = 32
    VersionLabel.Parent = ConfirmPanel

    local DescLabel = Instance.new("TextLabel")
    DescLabel.Size = UDim2.new(1, -50, 0, 50)
    DescLabel.Position = UDim2.new(0, 25, 0, 180)
    DescLabel.BackgroundTransparency = 1
    DescLabel.Text = description
    DescLabel.TextColor3 = Theme.TextSecondary
    DescLabel.TextScaled = true
    DescLabel.Font = Enum.Font.Gotham
    DescLabel.TextWrapped = true
    DescLabel.TextXAlignment = Enum.TextXAlignment.Center
    DescLabel.TextYAlignment = Enum.TextYAlignment.Top
    DescLabel.ZIndex = 32
    DescLabel.Parent = ConfirmPanel

    local ConfirmBtn = Instance.new("TextButton")
    ConfirmBtn.Size = UDim2.new(0.5, -30, 0, 42)
    ConfirmBtn.Position = UDim2.new(0, 22, 1, -56)
    ConfirmBtn.BackgroundColor3 = versionColor
    ConfirmBtn.Text = "Confirmar"
    ConfirmBtn.TextColor3 = Theme.TextPrimary
    ConfirmBtn.TextScaled = true
    ConfirmBtn.Font = Enum.Font.GothamBold
    ConfirmBtn.ZIndex = 32
    ConfirmBtn.Parent = ConfirmPanel

    local ConfirmBtnCorner = Instance.new("UICorner")
    ConfirmBtnCorner.CornerRadius = UDim.new(0, 10)
    ConfirmBtnCorner.Parent = ConfirmBtn

    local ConfirmBtnBorder = Instance.new("UIStroke")
    ConfirmBtnBorder.Color = versionColor:Lerp(Color3.new(1,1,1), 0.5)
    ConfirmBtnBorder.Thickness = 1.5
    ConfirmBtnBorder.Transparency = 0.3
    ConfirmBtnBorder.Parent = ConfirmBtn

    local CancelBtn = Instance.new("TextButton")
    CancelBtn.Size = UDim2.new(0.5, -30, 0, 42)
    CancelBtn.Position = UDim2.new(0.5, 8, 1, -56)
    CancelBtn.BackgroundColor3 = Theme.Tertiary
    CancelBtn.Text = "Cancelar"
    CancelBtn.TextColor3 = Theme.TextSecondary
    CancelBtn.TextScaled = true
    CancelBtn.Font = Enum.Font.GothamBold
    CancelBtn.ZIndex = 32
    CancelBtn.Parent = ConfirmPanel

    local CancelBtnCorner = Instance.new("UICorner")
    CancelBtnCorner.CornerRadius = UDim.new(0, 10)
    CancelBtnCorner.Parent = CancelBtn

    local CancelBorder = Instance.new("UIStroke")
    CancelBorder.Color = Theme.Border
    CancelBorder.Thickness = 1
    CancelBorder.Transparency = 0.3
    CancelBorder.Parent = CancelBtn

    ConfirmBtn.MouseEnter:Connect(function()
        TweenService:Create(ConfirmBtn, TweenInfo.new(0.2), {BackgroundColor3 = versionColor:Lerp(Color3.new(0,0,0), 0.2)}):Play()
        TweenService:Create(ConfirmBtnBorder, TweenInfo.new(0.2), {Transparency = 0}):Play()
    end)
    ConfirmBtn.MouseLeave:Connect(function()
        TweenService:Create(ConfirmBtn, TweenInfo.new(0.2), {BackgroundColor3 = versionColor}):Play()
        TweenService:Create(ConfirmBtnBorder, TweenInfo.new(0.2), {Transparency = 0.3}):Play()
    end)

    CancelBtn.MouseEnter:Connect(function()
        TweenService:Create(CancelBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Border, TextColor3 = Theme.TextPrimary}):Play()
    end)
    CancelBtn.MouseLeave:Connect(function()
        TweenService:Create(CancelBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Tertiary, TextColor3 = Theme.TextSecondary}):Play()
    end)

    ConfirmPanel:TweenSize(
        UDim2.new(0, 440, 0, 290),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Back,
        0.4,
        true
    )

    -- 🔒 Flag de proteção para não executar 2x
    local hasClosed = false

    local function closeConfirmation(callback)
        if hasClosed then return end
        hasClosed = true
        
        if ConfirmPanel and ConfirmPanel.Parent then
            ConfirmPanel:TweenSize(
                UDim2.new(0, 0, 0, 0),
                Enum.EasingDirection.In,
                Enum.EasingStyle.Back,
                0.25,
                true
            )
            task.wait(0.3)
            if ConfirmPanel.Parent then
                ConfirmPanel:Destroy()
            end
        end
        isConfirmationOpen = false
        if callback then callback() end
    end

    ConfirmBtn.MouseButton1Click:Connect(function()
        closeConfirmation(onConfirm)
    end)

    CancelBtn.MouseButton1Click:Connect(function()
        closeConfirmation(nil)
    end)
end

-- =======================================================
-- 🎯 FUNÇÃO PARA CRIAR OS CARDS (COM TRAVA DE SEGURANÇA)
-- =======================================================
local function createCard(name, color, posX, titleText, featuresText, scriptLink, description)
    local Card = Instance.new("Frame")
    Card.Name = name
    Card.Size = UDim2.new(0, 175, 0, 250) 
    Card.Position = UDim2.new(0, posX, 0, 85) 
    Card.BackgroundColor3 = color
    Card.BorderSizePixel = 0
    Card.Parent = MainFrame

    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 14)
    CardCorner.Parent = Card

    local CardStroke = Instance.new("UIStroke")
    CardStroke.Color = color:Lerp(Color3.new(1,1,1), 0.5)
    CardStroke.Thickness = 2
    CardStroke.Transparency = 0.2
    CardStroke.Parent = Card

    local CardShadow = Instance.new("ImageLabel")
    CardShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    CardShadow.BackgroundTransparency = 1
    CardShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    CardShadow.Size = UDim2.new(1, 20, 1, 20)
    CardShadow.ZIndex = 0
    CardShadow.Image = "rbxassetid://6014261993"
    CardShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    CardShadow.ImageTransparency = 0.7
    CardShadow.ScaleType = Enum.ScaleType.Slice
    CardShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    CardShadow.Parent = Card

    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 8, 0, 8)
    Dot.Position = UDim2.new(0, 16, 0, 22)
    Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Dot.BackgroundTransparency = 0.2
    Dot.BorderSizePixel = 0
    Dot.ZIndex = 3
    Dot.Parent = Card

    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(1, 0)
    DotCorner.Parent = Dot

    local CardTitle = Instance.new("TextLabel")
    CardTitle.Size = UDim2.new(1, -35, 0, 22)
    CardTitle.Position = UDim2.new(0, 30, 0, 15)
    CardTitle.BackgroundTransparency = 1
    CardTitle.Text = titleText
    CardTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    CardTitle.TextScaled = true
    CardTitle.Font = Enum.Font.GothamBold
    CardTitle.TextXAlignment = Enum.TextXAlignment.Left
    CardTitle.ZIndex = 3
    CardTitle.Parent = Card

    local CardDivider = Instance.new("Frame")
    CardDivider.Size = UDim2.new(1, -32, 0, 1)
    CardDivider.Position = UDim2.new(0, 16, 0, 48)
    CardDivider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    CardDivider.BackgroundTransparency = 0.7
    CardDivider.BorderSizePixel = 0
    CardDivider.ZIndex = 3
    CardDivider.Parent = Card

    local FeaturesLabel = Instance.new("TextLabel")
    FeaturesLabel.Size = UDim2.new(1, -32, 0, 140)
    FeaturesLabel.Position = UDim2.new(0, 16, 0, 60)
    FeaturesLabel.BackgroundTransparency = 1
    FeaturesLabel.Text = featuresText
    FeaturesLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    FeaturesLabel.TextTransparency = 0.05
    FeaturesLabel.TextScaled = true
    FeaturesLabel.Font = Enum.Font.GothamBold
    FeaturesLabel.TextXAlignment = Enum.TextXAlignment.Left
    FeaturesLabel.TextYAlignment = Enum.TextYAlignment.Top
    FeaturesLabel.TextWrapped = true
    FeaturesLabel.ZIndex = 3
    FeaturesLabel.Parent = Card

    local LoadButton = Instance.new("TextButton")
    LoadButton.Size = UDim2.new(1, 0, 1, 0)
    LoadButton.BackgroundTransparency = 1
    LoadButton.Text = ""
    LoadButton.ZIndex = 4
    LoadButton.Parent = Card

    LoadButton.MouseEnter:Connect(function()
        -- 🔒 Não mostra hover se estiver carregando
        if isLoading then return end
        TweenService:Create(Card, TweenInfo.new(0.2), {BackgroundColor3 = color:Lerp(Color3.new(0,0,0), 0.2)}):Play()
        TweenService:Create(CardStroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
    end)
    LoadButton.MouseLeave:Connect(function()
        TweenService:Create(Card, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
        TweenService:Create(CardStroke, TweenInfo.new(0.2), {Transparency = 0.2}):Play()
    end)

    LoadButton.MouseButton1Click:Connect(function()
        -- 🔒 TRAVA: se já estiver carregando ou com confirmação aberta, não faz nada
        if isLoading or isConfirmationOpen then return end
        
        showConfirmation(titleText, color, description, function()
            -- 🔒 TRAVA DUPLA: só executa se ainda não estiver carregando
            if isLoading then return end
            
            MainFrame.Visible = false
            ReopenButton.Visible = false
            
            showLoadingScreen(titleText, color, function()
                -- 🔒 Executa o script com segurança
                local success, err = pcall(function()
                    loadstring(game:HttpGet(scriptLink))()
                end)
                
                if not success then
                    -- Erro: restaura o painel
                    isLoading = false
                    MainFrame.Visible = true
                    ReopenButton.Visible = false
                    
                    local errorGui = Instance.new("TextLabel")
                    errorGui.Size = UDim2.new(0, 350, 0, 60)
                    errorGui.Position = UDim2.new(0.5, -175, 0.1, 0)
                    errorGui.BackgroundColor3 = Theme.Background
                    errorGui.TextColor3 = Theme.Error
                    errorGui.Text = "Erro ao carregar script!\nVerifique sua conexão."
                    errorGui.Font = Enum.Font.GothamBold
                    errorGui.TextScaled = true
                    errorGui.ZIndex = 60
                    errorGui.Parent = ScreenGui
                    
                    local errCorner = Instance.new("UICorner")
                    errCorner.CornerRadius = UDim.new(0, 10)
                    errCorner.Parent = errorGui
                    
                    local errBorder = Instance.new("UIStroke")
                    errBorder.Color = Theme.Error
                    errBorder.Thickness = 1.5
                    errBorder.Transparency = 0.3
                    errBorder.Parent = errorGui
                    
                    task.wait(5)
                    if errorGui.Parent then errorGui:Destroy() end
                else
                    -- Sucesso: destrói tudo
                    if ScreenGui and ScreenGui.Parent then
                        ScreenGui:Destroy()
                    end
                end
            end)
        end)
    end)
end

-- =======================================================
-- CRIANDO OS 3 CARDS
-- =======================================================

createCard(
    "BASICA", 
    VersionColors.BASICA, 
    25, 
    "Versão Básica", 
    "- Anti-Cheat Bypass\n- Sem Key\n- Recursos Essenciais\n- Estável",
    "https://raw.githubusercontent.com/ghosthub031-dev/Ghost-rivals/refs/heads/main/ghost_scripts_rivals_lite.lua",
    "Versão otimizada especialmente para dispositivos mais fracos. Leve, rápida e funcional — ideal para quem quer desempenho sem travamentos."
)

createCard(
    "PADRAO", 
    VersionColors.PADRAO, 
    212, 
    "Versão Padrão", 
    "- Anti-Cheat Melhorado\n- Sem Key\n- Todos os Recursos\n- Sem Key",
    "https://raw.githubusercontent.com/ghosthub031-dev/Ghost-rivals/refs/heads/main/GHOST_SCRIPTS_RIVALS_.lua",
    "Versão completa e equilibrada, com todos os recursos essenciais. Recomendada para a maioria dos jogadores, mas pode apresentar lentidão em dispositivos fracos."
)

createCard(
    "PRO", 
    VersionColors.PRO, 
    399, 
    "Versão Pro", 
    "- Melhor Anti-Cheat\n- Sem Key\n- Todos os Recursos\n- Foco em Performance",
    "https://raw.githubusercontent.com/ghosthub031-dev/Ghost-rivals/refs/heads/main/GhostScripts_Rivals_versao_pro.lua",
    "Versão pro e mais pesada, com o máximo de recursos disponíveis. Melhor experiência de jogo possível — pode conter travamentos dependendo dos dispositivos."
)