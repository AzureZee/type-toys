#Requires AutoHotkey v2.0
#Include lib\JSON.ahk ; https://github.com/thqby/ahk2_lib/blob/master/JSON.ahk
#Include lib\Utils.ahk
#Include lib\RunAsAdmin.ahk
RunAsAdmin()

; 鼠标侧键上
XButton2::
{
    Copy()
}

; 鼠标侧键下
XButton1::
{
    Paste()
}
; CapsLock 映射为 Win+Space，切换输入布局（中英文）
SetCapsLockState "AlwaysOff"
CapsLock:: {
    SendInput("#{Space}")
}
CapsLock & q:: addProc()

#HotIf enProcs.Length == 0
CapsLock & q:: addProc_inputBox()
#HotIf

global setToEn := Map()
global enProcs := []
; 解析 config.json
try {
    config := JSON.Parse(FileRead(A_ScriptDir . "\config.json"))
    enProcs := config["en"]
    if enProcs.Length == 0 {
        inputProc()
    } else {
        for procName in enProcs {
            ; 初始化所有配置进程为“未设置”状态
            setToEn[procName] := false
        }
    }
} catch {
    MsgBox("无法加载 config.json, 请检查文件是否存在且格式正确。", "错误", "OK Icon!")
    ExitApp
}

; 定期检查配置进程的启动状态，只在打开时切换输入法
SetTimer(CheckProcs, 2000)

; 切换到英文键盘布局
Switch_EnKL(hWnd) {
    static enKLID := 0x04090409
    static cnKLID := 0x08040804
    static GetWinThreadId(hwnd) => DllCall("GetWindowThreadProcessId", "ptr", hwnd, "ptr", 0, "int")
    static GetWinActiveKLID(threadId) => DllCall("GetKeyboardLayout", "Uint", threadId, "ptr")
    ; 向窗口发送 WM_INPUTLANGCHANGEREQUEST 消息切换输入法
    static SetWinKLID(hKL, hWnd) => PostMessage(0x50, 0, hKL, hWnd)


    ; 获取该线程的键盘布局ID
    KLID := GetWinActiveKLID(GetWinThreadId(hWnd))

    if KLID == cnKLID {
        SetWinKLID(enKLID, hWnd)
    }
}

; 检查进程的启动状态，只在首次打开时切换输入法
CheckProcs() {
    for proc in enProcs {
        ; 进程是否打开, 若关闭则重置标记
        if (!ProcessExist(proc)) {
            setToEn[proc] := false
            continue
        }
        try {
            ; 检查指定进程是否有活动窗口并获取句柄, 以及是否已切换过一次
            if (hWnd := WinActive("ahk_exe " . proc)) && !setToEn[proc] {
                Switch_EnKL(hWnd)
                ; 标记为已设置
                setToEn[proc] := true
            }
        } catch {
            continue
        }
    }
}

addProc(*) {
    proc := WinGetProcessName(WinExist("A"))

    if !setToEn.Has(proc)
    {
        setToEn[proc] := false
        enProcs.Push(proc)
        config["en"] := enProcs
        jsonObj := JSON.stringify(config, ,)
        FileOpen(A_ScriptDir . "\config.json", "rw",).Write(jsonObj)
        ; MsgBox "You entered '" Join("`n", enProcs*) "'."
    }
}

inputProc(*) {
    result := InputBox("请使用Capslock+Q获取活动窗口进程名", "添加进程", "w260 h100")
    if result.Result == "OK" {
        proc := result.Value
        if proc != "" && !setToEn.Has(proc)
        {
            setToEn[proc] := false
            enProcs.Push(proc)
            config["en"] := enProcs
            jsonObj := JSON.stringify(config, ,)
            FileOpen(A_ScriptDir . "\config.json", "rw",).Write(jsonObj)
            ; MsgBox "You entered '" Join("`n", enProcs*) "'."
        }
    }
}
addProc_inputBox(*) {
    proc := WinGetProcessName(WinExist("A"))
    EditPaste(proc, "Edit1", "添加进程")
    WinActivate("添加进程")
}
; FormatKLID(KLID) => Format("0x{:08X}", KLID)
