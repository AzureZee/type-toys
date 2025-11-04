#Requires AutoHotkey v2.0


XButton2::
{
    A_Clipboard := ""  ; 清空剪贴板
    Send "^c"  ; 仍需短暂发送 Ctrl+C 来“触发”应用复制（无可避免，除非用 API）
    ClipWait(1)  ; 等待 1 秒内剪贴板有内容
    if (A_Clipboard != "") {
        ToolTip("已复制到剪贴板")  ; 提示
        SetTimer(() => ToolTip(), -1000)  ; 1 秒后隐藏
    }
    return
}


XButton1::
{
    if (A_Clipboard != "") {  ; 检查剪贴板有内容
        Send "^v"  ; 发送 Ctrl+V 
        ToolTip("已粘贴")  ; 提示
        SetTimer(() => ToolTip(), -1000)
    }
    return
}