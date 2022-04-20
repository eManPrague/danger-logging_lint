package cz.eman.logging.lint

class NewFile {

    fun runLogDebug() {
        "Text to ignore new $ignoredVar"

        logDebug { "Log debug new" }
        logDebug("Log debug new")
        logDebug { "Log debug new $var" }
        logDebug("Log debug new $var")
        logDebug {
            "Log debug new"
        }
        logDebug(
            "Log debug new"
        )
        logDebug {
            "Log debug new $var"
        }
        logDebug(
            "Log debug new $var"
        )
        logDebug {
            "Log debug new"
            +"Second line new"
        }
        logDebug(
            "Log debug new"
                    + "Second line new"
        )
        logDebug {
            "Log debug new"
            +"Second line new $var"
        }
        logDebug(
            "Log debug new"
                    + "Second line new $var"
        )
    }

    fun runLogInfo() {
        "Text to ignore modified $ignoredVar"

        logInfo { "Log info new" }
        logInfo("Log info new")
        logInfo { "Log info new $var" }
        logInfo("Log info new $var")
        logInfo {
            "Log info new"
        }
        logInfo(
            "Log info new"
        )
        logInfo {
            "Log info new $var"
        }
        logInfo(
            "Log info new $var"
        )
        logInfo {
            "Log info new"
            +"Second line new"
        }
        logInfo(
            "Log info new"
                    + "Second line new"
        )
        logInfo {
            "Log info new"
            +"Second line new $var"
        }
        logInfo(
            "Log info new"
                    + "Second line new $var"
        )
    }
}