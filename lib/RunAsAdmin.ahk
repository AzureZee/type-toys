#Requires AutoHotkey v2.0

RunAsAdmin() {
    ; 使用 Windows API GetCommandLine 获取当前进程的完整命令行字符串。
    ; 这是为了判断是否已经带有 /restart 参数（用于避免重复提权）。
    fullCmd := DllCall("GetCommandLine", "str")

    ; 如果当前已是管理员权限或命令行中没有 /restart 参数 , 无需处理
    ; RegExMatch(..., " /restart(?!\S)") 用正则判断 /restart 后面不能跟其他字符，避免误判。
    if A_IsAdmin || RegExMatch(fullCmd, " /restart(?!\S)") {
        return
    }

    try {
        ; 如果是编译后的 EXE（A_IsCompiled = true），直接以管理员身份运行自身并附加 /restart 参数。
        ; 如果是 .ahk 源文件，则调用 AHK 解释器（A_AhkPath）以管理员身份运行脚本。
        ; 加上 /restart 参数是为了避免再次进入这个提权逻辑，防止无限循环。
        if A_IsCompiled {
            Run '*RunAs "' A_ScriptFullPath '" /restart'
        } else {
            Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
        }
    } catch as e {
        MsgBox "❌ 自动提权失败：" e.Message
    }
    ExitApp
}