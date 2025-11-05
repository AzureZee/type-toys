#Requires AutoHotkey v2.0 

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
; see https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-systemparametersinfoa
; and https://learn.microsoft.com/en-us/windows/win32/inputdev/about-keyboard-input
SetDefaultKeyboard(LocaleID) {
    ; 用于设置系统默认输入语言（键盘布局）。
    static SPI_SETDEFAULTINPUTLANG := 0x005A 
    static SPIF_SENDWININICHANGE := 0x0002

    ; 加载键盘布局
    ; see https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-loadkeyboardlayouta
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