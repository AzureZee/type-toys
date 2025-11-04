#Requires AutoHotkey v2.0

; --- 通过API调用直接切换输入法 ---

; 定义不同语言的键盘布局句柄 (HKL)。
; 这些是标准的十六进制值，通常在所有Windows系统上通用。
global HKL_ENG := "0x4090409"  ; 美式英语
global HKL_CHS := "0x8040804"  ; 简体中文 (PRC)

; 当按下 CapsLock 键时，调用我们自定义的切换函数
CapsLock:: SwitchLayout()

/**
 * 切换键盘布局的函数
 */
SwitchLayout() {
    ; 获取当前活动窗口的句柄 (HWND)
    hwnd := WinActive("A")

    ; 获取当前活动窗口线程的键盘布局
    ; 使用 DllCall 来调用 Windows API 函数
    threadId := DllCall("GetWindowThreadProcessId", "Ptr", hwnd, "Ptr", 0)
    currentHKL := DllCall("GetKeyboardLayout", "UInt", threadId, "Ptr")

    ; 判断当前布局，并决定要切换到哪一个
    ; 如果当前是中文，则目标为英文；否则，目标为中文。
    targetHKL := (currentHKL = HKL_CHS) ? HKL_ENG : HKL_CHS

    ; 发送 WM_INPUTLANGCHANGEREQUEST (0x50) 消息来改变键盘布局
    ; PostMessage 比 SendMessage 更合适，因为它不会等待窗口响应。
    PostMessage(0x50, 0, targetHKL, hwnd)
}