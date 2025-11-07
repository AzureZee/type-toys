#Requires AutoHotkey v2.0
#Include lib\JSON.ahk

; 解析 config.json
try {
    config := JSON.Parse(FileRead(A_ScriptDir . "\config.json"))
    enProcs := config["en"]
} catch {
    MsgBox("无法加载 config.json, 请检查文件是否存在且格式正确。", "错误", "OK Icon!")
    ExitApp
}

setToEn := Map()
for proc in enProcs {
    ; 初始化所有配置进程为“未设置”状态
    setToEn[proc] := false
}

; 定期检查配置进程的启动状态，只在首次打开时切换输入法
SetTimer(CheckProcs, 2000)

; 切换到英文键盘布局
Switch_EnKL(hWnd) {
    static enHKL := 0x04090409
    static cnHKL := 0x08040804

    ; 获取与该窗口关联的线程ID
    threadId := GetWindowThreadProcessId(hWnd, 0)
    ; Tip("threadId " . threadId)

    ; 获取该线程的键盘布局ID
    hKL := GetKeyboardLayout(threadId)
    ; Tip("HKL " . FormatHKL(hKL))

    if hKL == cnHKL {
        Post_WM_INPUTLANGCHANGEREQUEST(enHKL, hWnd)
        ; Tip("已切换到英文输入法")
    }
}

; 检查进程的启动状态，只在首次打开时切换输入法
CheckProcs() {
    ; Tip("check")
    for proc in enProcs {

        ; 进程是否打开, 若关闭则重置标记
        if (!ProcessExist(proc)) {
            ; Tip("noExist " . proc)

            setToEn[proc] := false
            continue
        }
        try {
            ; Tip("Exist " . proc)
            
            ; 检查指定进程是否有活动窗口并获取句柄, 以及是否已切换过一次
            if (hWnd := WinActive("ahk_exe " . proc)) && !setToEn[proc] {
                ; Tip("Hwnd " . hWnd)
                ; Tip("current " . proc)
                ; Tip("switch " . proc)

                Switch_EnKL(hWnd)
                ; 标记为已设置
                setToEn[proc] := true

            }
        } catch {
            ; Tip("Error")
            continue
        }
    }

}
FormatHKL(hKL) => Format("0x{:08X}", hKL)
/**
 * 自动关闭的提示窗口 
 * @param message 要提示的文本
 * @param {number} time 超时后关闭
 */
Tip(message, time := -1500) {
    ToolTip(message)
    SetTimer(() => ToolTip(), time)
    ; Sleep(1000)
}

; 向窗口发送 WM_INPUTLANGCHANGEREQUEST 消息切换输入法
Post_WM_INPUTLANGCHANGEREQUEST(hKL, hWnd) {
    PostMessage(0x50, 0, hKL, hWnd)
}
GetWindowThreadProcessId(hWnd, lpdwProcessId) => DllCall('User32\GetWindowThreadProcessId', 'ptr', hWnd, 'ptr', lpdwProcessId, 'uint')
GetKeyboardLayout(idThread) => DllCall('User32\GetKeyboardLayout', 'uint', idThread, 'ptr')