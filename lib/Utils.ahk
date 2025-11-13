/**
 * 自动关闭的提示窗口 
 * @param message 要提示的文本
 * @param {number} time 超时后关闭
 */
Tip(message, time := -1500) {
  ToolTip(message)
  SetTimer(() => ToolTip(), time)
}

Copy(*) {
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
Paste(*) {
    if (A_Clipboard != "") {
        Send "^v"
        Tip("已粘贴", -1000)
    }
    return
}