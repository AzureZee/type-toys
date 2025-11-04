#Requires AutoHotkey v2.0

; #UseHook true  ; 强制所有热键使用低级键盘/鼠标钩子，解决冲突
#Include <JSON>
InstallKeybdHook  ; 显式安装键盘钩子（CapsLock 需要）

; CapsLock 映射为 Win+Space，切换输入布局（中英文）

; SetCapsLockState "AlwaysOff"
CapsLock:: SendInput("#{Space}")

; 解析 config.json
try {
    config := JSON.Parse(FileRead(A_ScriptDir . "\config.json"))
    en_progs := config["en"]
} catch {
    MsgBox("无法加载 config.json，请检查文件是否存在且格式正确。", "错误", "OK Icon!")
    ExitApp
}

; 跟踪已见进程的 Map
seen := Map()
for prog in en_progs {
    seen[prog] := false
}

; 每秒检查一次进程启动
SetTimer(CheckProcs, 1000)

CheckProcs() {
    for prog in en_progs {
        exists := ProcessExist(prog)
        if (!exists) {
            seen[prog] := false
            continue
        }
        if (!seen[prog]) {
            ; 切换到英文键盘布局 (US English: 0x04090409)
            SetDefaultKeyboard(0x04090409)
            seen[prog] := true
            ; 可选：添加提示
            ToolTip("已切换到英文输入法: " . prog)
            SetTimer(() => ToolTip(), -2000)
        }
    }
}

; 获取当前默认键盘布局 (HKL)
GetDefaultKeyboard() {
    hWnd := WinExist("A")
    if (!hWnd)
        hWnd := WinExist()  ; 当前活动窗口
    ThreadID := DllCall("GetWindowThreadProcessId", "Ptr", hWnd, "UInt*", 0)
    InputLocaleID := DllCall("GetKeyboardLayout", "UInt", ThreadID, "Ptr")
    return Format("{:#x}", InputLocaleID)
}

; 设置默认键盘布局
SetDefaultKeyboard(LocaleID) {
    static SPI_SETDEFAULTINPUTLANG := 0x005A
    static SPIF_SENDWININICHANGE := 0x0002

    ; 加载键盘布局
    Lan := DllCall("LoadKeyboardLayout", "Str", Format("{:08x}", LocaleID), "Int", 0, "Ptr")

    ; 设置系统默认输入语言
    binaryLocaleID := Buffer(4, 0)
    NumPut("UInt", LocaleID, binaryLocaleID, 0)
    DllCall("SystemParametersInfo", "UInt", SPI_SETDEFAULTINPUTLANG, "UInt", 0, "Ptr", binaryLocaleID, "UInt", SPIF_SENDWININICHANGE)

    ; 广播到所有窗口 (WM_INPUTLANGCHANGE: 0x0051)
    for hwnd in WinGetList() {
        PostMessage(0x0051, 0, Lan, , hwnd)
    }
}