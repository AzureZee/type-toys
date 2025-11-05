#Requires AutoHotkey v2.0
#Include lib\JSON.ahk
#Include lib\Utils.ahk
#Include KeyboradLayout.ahk

; 解析 config.json
try {
    config := JSON.Parse(FileRead(A_ScriptDir . "\config.json"))
    en_progs := config["en"]
} catch {
    MsgBox("无法加载 config.json, 请检查文件是否存在且格式正确。", "错误", "OK Icon!")
    ExitApp
}

; 初始化所有配置进程为“未打开”状态
progState := Map()
for prog in en_progs {
    progState[prog] := false
}

; 定期检查配置进程的启动状态，只在首次打开时切换输入法
SetTimer(CheckProcs, 2000)

CheckProcs() {
    for prog in en_progs {
        notExist := !ProcessExist(prog)
        if (notExist) {
            progState[prog] := false
            continue
        }
        if (!progState[prog]) {
            ; 切换到英文键盘布局 (US English: 0x04090409)
            SetDefaultKeyboard(0x04090409)
            progState[prog] := true

            Tip("已切换到英文输入法")
        }
    }
}