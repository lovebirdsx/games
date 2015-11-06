local DEBUG = 1
local INFO = 2
local WARNING = 3
local FATAL = 4

local LOG_LEVEL_MAP = {
	debug = DEBUG,
	info = INFO,
	warning = WARNING,
	fatal = FATAL,
}

local log_level = DEBUG

function _log_printf(desire, prefix, fmt, ...)
	if log_level <= desire then
		io.write(prefix)
		printf(string.format(fmt, ...))
	end
end

function set_log_level(level)
	log_level = LOG_LEVEL_MAP[level]
end

function debug(fmt, ...)
	_log_printf(DEBUG, 'D:', fmt, ...)
end

function info(fmt, ...)
	_log_printf(INFO, 'I:', fmt, ...)
end

function warning(fmt, ...)
	_log_printf(WARNING, 'W:', fmt, ...)
end

function fatal(fmt, ...)
	_log_printf(FATAL, 'F:', fmt, ...)
end
