package cz.eman.logging.lint

class NewFile {

    fun runLogDebug() {
        logDebug { "Log debug" }
        logDebug("Log debug")
        logDebug { "Log debug $var" }
        logDebug("Log debug $var")
        logDebug {
            "Log debug"
        }
        logDebug(
            "Log debug"
        )
        logDebug {
            "Log debug $var"
        }
        logDebug(
            "Log debug $var"
        )
        logDebug {
            "Log debug"
            +"Second line"
        }
        logDebug(
            "Log debug"
                    + "Second line"
        )
        logDebug {
            "Log debug"
            +"Second line $var"
        }
        logDebug(
            "Log debug"
                    + "Second line $var"
        )
    }

    fun runLogInfo() {
        logInfo { "Log debug" }
        logInfo("Log debug")
        logInfo { "Log debug $var" }
        logInfo("Log debug $var")
        logInfo {
            "Log debug"
        }
        logInfo(
            "Log debug"
        )
        logInfo {
            "Log debug $var"
        }
        logInfo(
            "Log debug $var"
        )
        logInfo {
            "Log debug"
            +"Second line"
        }
        logInfo(
            "Log debug"
                    + "Second line"
        )
        logInfo {
            "Log debug"
            +"Second line $var"
        }
        logInfo(
            "Log debug"
                    + "Second line $var"
        )
    }
}