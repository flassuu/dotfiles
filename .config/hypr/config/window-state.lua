-- █ █ █ █▄ █ █▀▄ █▀█ █ █ █    █▀ ▀█▀ ▄▀█ ▀█▀ █▀▀
-- ▀▄▀ █ █ █ ▀█ █▄▀ █▄█ █▄█ █▄ ▄█  █  █▀█  █  ██▄
--
-- Window state: re-apply remembered floating geometry when a window opens.
-- Saved with SUPER + I (`hypr-window-state save -fsp`), stored under
-- $XDG_STATE_HOME/hypr. The JSON is canonical; this module reads the Lua cache
-- generated next to it on every `window.open`, so saves are live immediately.
--
-- Matching is class/app-id + initial title. The live title is intentionally
-- ignored: it changes with the document, the initial title does not.
-- Docs: https://wiki.hypr.land/configuring/core/lua-utilities/

local STATE_DIR = os.getenv("XDG_STATE_HOME") or ((os.getenv("HOME") or "") .. "/.local/state")
local CACHE = STATE_DIR .. "/hypr/window-state.lua"

local function load_cache()
	local chunk = loadfile(CACHE)
	if not chunk then
		return nil
	end
	local ok, data = pcall(chunk)
	if not ok or type(data) ~= "table" or type(data.records) ~= "table" then
		return nil
	end
	return data
end

-- Score a record against a window; nil means "does not match".
-- Variant titles win over the class default; an exact initial title wins over
-- a pattern; xwayland is only a tie-breaker.
local function score(rec, w)
	local cls = w.class or ""
	local initial_cls = w.initial_class or cls
	if not (rec.class == cls or rec.initial_class == cls or rec.class == initial_cls or rec.initial_class == initial_cls) then
		return nil
	end

	local result
	if rec.title_pattern then
		if not (w.initial_title or ""):find(rec.title_pattern) then
			return nil
		end
		result = 10 + #rec.title_pattern
	elseif rec.variant then
		if rec.title_exact ~= w.initial_title then
			return nil
		end
		result = 20
	else
		result = 0
	end

	if rec.xwayland ~= nil and rec.xwayland ~= w.xwayland then
		result = result - 0.5
	end
	return result
end

local function pick(records, w)
	local best, best_score = nil, -1
	for _, rec in ipairs(records) do
		local value = score(rec, w)
		if value and value > best_score then
			best, best_score = rec, value
		end
	end
	return best
end

local function logical_size(monitor)
	local scale = monitor.scale or 1
	return math.floor(monitor.size.width / scale), math.floor(monitor.size.height / scale)
end

local function monitor_by_name(name)
	if not name then
		return nil
	end
	for _, monitor in ipairs(hl.get_monitors()) do
		if monitor.name == name then
			return monitor
		end
	end
	return nil
end

-- Prefer the monitor the window was saved on; fall back to the current one.
-- Keeps at least 64 px of the window grabbable on screen.
local function position_for(rec, w)
	local monitor = monitor_by_name(rec.monitor) or w.monitor
	if not monitor then
		return nil
	end

	local width = rec.w or 100
	local height = rec.h or 100
	local monitor_x = monitor.position.x
	local monitor_y = monitor.position.y
	local monitor_w, monitor_h = logical_size(monitor)

	local x = monitor_x + (rec.rel_x or ((rec.x or monitor_x) - monitor_x))
	local y = monitor_y + (rec.rel_y or ((rec.y or monitor_y) - monitor_y))

	x = math.max(monitor_x - width + 64, math.min(x, monitor_x + monitor_w - 64))
	y = math.max(monitor_y, math.min(y, monitor_y + monitor_h - 64))
	return math.floor(x), math.floor(y)
end

local function apply(w, rec, config)
	local selector = "address:" .. w.address

	if rec.floating ~= nil and w.floating ~= rec.floating then
		hl.dispatch(hl.dsp.window.float({ window = selector, action = rec.floating and "enable" or "disable" }))
	end

	-- Geometry is meaningless for tiled windows: only resize/move when the
	-- window is floating (or was just made floating above).
	local floating = rec.floating
	if floating == nil then
		floating = w.floating
	end

	if floating then
		if rec.w and rec.h then
			hl.dispatch(hl.dsp.window.resize({ window = selector, x = rec.w, y = rec.h, relative = false }))
		end
		if rec.centered then
			hl.dispatch(hl.dsp.window.center({ window = selector }))
		elseif rec.rel_x ~= nil or rec.x ~= nil then
			local x, y = position_for(rec, w)
			if x then
				hl.dispatch(hl.dsp.window.move({ window = selector, x = x, y = y, relative = false }))
			end
		end
	end

	-- Workspace moves are opt-in: `hypr-window-state config set apply_workspace true`.
	if config.apply_workspace and rec.ws then
		hl.dispatch(hl.dsp.window.move({ window = selector, workspace = rec.ws, follow = false }))
	end
end

-- Apps often resize themselves just after the first map (client-side minimums,
-- GTK header bars, Electron late layout). Re-apply once, only if the size
-- actually drifted, so a correct restore is not disturbed.
local function settle(address, rec, config)
	local w = hl.get_window("address:" .. address)
	if not w or not w.floating then
		return
	end
	if rec.w and rec.h and (math.abs(w.size.x - rec.w) > 4 or math.abs(w.size.y - rec.h) > 4) then
		apply(w, rec, config)
	end
end

hl.on("window.open", function(w)
	if not w or not w.address then
		return
	end
	if w.pinned or (w.fullscreen or 0) ~= 0 then
		return
	end

	local data = load_cache()
	if not data then
		return
	end

	local rec = pick(data.records, w)
	if not rec then
		return
	end

	local config = data.config or {}
	apply(w, rec, config)

	local delay = config.settle_ms or 0
	if delay > 0 then
		hl.timer(function()
			settle(w.address, rec, config)
		end, { timeout = delay, type = "oneshot" })
	end
end)
