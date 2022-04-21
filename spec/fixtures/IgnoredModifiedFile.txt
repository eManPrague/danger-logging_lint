package cz.eman.logging.lint

class ModifiedFile {

    fun runLogDebug() {
        "Text to ignore modified $ignoredVar"

        logDebug { "Log debug modified" }
        logDebug("Log debug modified")
        logDebug { "Log debug modified $var" }
        logDebug("Log debug modified $var")
        logDebug {
            "Log debug modified"
        }
        logDebug(
            "Log debug modified"
        )
        logDebug {
            "Log debug modified $var"
        }
        logDebug(
            "Log debug modified $var"
        )
        logDebug {
            "Log debug modified"
            +"Second line modified"
        }
        logDebug(
            "Log debug modified"
                    + "Second line modified"
        )
        logDebug {
            "Log debug modified"
            +"Second line modified debug $var"
        }
        logDebug(
            "Log debug modified"
                    + "Second line modified debug $var"
        )
        logDebug(
            "Log debug modifies"
                 + message
        )
        logDebug(message.var)
        logDebug(
            message.var
        )
        logDebug {
            "Log debug modifies"
                 + message
        }
        logDebug { message.var }
        logDebug {
            message.var
        }
    }

    fun runLogInfo() {
        "Text to ignore modified $ignoredVar"

        logInfo { "Log info modified" }
        logInfo("Log info modified")
        logInfo { "Log info modified $var" }
        logInfo("Log info modified $var")
        logInfo {
            "Log info modified"
        }
        logInfo(
            "Log info modified"
        )
        logInfo {
            "Log info modified $var"
        }
        logInfo(
            "Log info modified $var"
        )
        logInfo {
            "Log info modified"
            +"Second line modified"
        }
        logInfo(
            "Log info modified"
                    + "Second line modified"
        )
        logInfo {
            "Log info modified"
            +"Second line modified info $var"
        }
        logInfo(
            "Log info modified"
                    + "Second line modified info $var"
        )
        logInfo(
            "Log debug modifies"
                 + message
                 + "another line"
        )
        logInfo(message.var)
        logInfo(
            message.var
        )
        logInfo {
            "Log debug modifies {some text}"
                 + message
                 + "another line"
        }
        logInfo { message.var }
        logInfo {
            message.var
        }
    }
}