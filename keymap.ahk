#Requires AutoHotkey v2.0
#Include lib\Utils.ahk
; #Include lib\RunAsAdmin.ahk
; RunAsAdmin()

; CapsLock 映射为 Win+Space，切换输入布局（中英文）
; SetCapsLockState "AlwaysOff"
CapsLock:: SendInput("#{Space}")

; 鼠标侧键上
XButton2::
{
    A_Clipboard := ""
    Send "^c"
    ClipWait(0.4)
    text := A_Clipboard
    trimmed := RTrim(text, " `t`r`n")
    if text == trimmed {
        Tip("已复制", -1000)
        return
    }
    A_Clipboard := trimmed
    Tip("已复制 and trim", -1000)
    return
}

; 鼠标侧键下
XButton1::
{
    if (A_Clipboard != "") {
        Send "^v"
        Tip("已粘贴", -1000)
    }
    return
}