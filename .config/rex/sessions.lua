-- Save and restore sessions across Rex server restarts and reboots.
--
-- A snapshot holds every session's label, its windows, their split layouts
-- and floating layers, and each pane's label, directory, and (for programs in
-- the allowlist below) the command to start again. Scrollback and running
-- processes are not saved.
--
-- Saving happens automatically from a zsh precmd hook (see ~/.zshrc), which
-- runs `rex do sessions_save mode=auto` at most every few seconds. An
-- automatic save never overwrites a snapshot taken by a different server
-- instance, so the empty session Rex starts with after a reboot can't replace
-- the one you want back. Run Restore Sessions (ctrl+b>R) first, or Save
-- Sessions by hand to start over from what is open now.

local terminal = "com.superlogical.terminal"
local shell_flavor = "com.superlogical.terminal.shell"

local home = os.getenv("HOME")
local state_dir = (os.getenv("XDG_STATE_HOME") or (home .. "/.local/state")) .. "/rex/sessions"
local latest_path = state_dir .. "/latest.json"
local history_dir = state_dir .. "/history"
local history_keep = 24
local history_every = 15 * 60 -- seconds between history copies

-- Programs started again on restore, by typing a command into the pane's
-- fresh shell, so quitting the program leaves you at a prompt in the same
-- directory. true repeats the program's own command line; a string replaces
-- it; a function is called with the process and returns the command. Panes
-- running anything else get a plain shell.
local programs = {
  nvim = true,
  vim = true,
  yazi = true,
  lazygit = true,
  -- Claude Code records each running process's conversation in
  -- ~/.claude/sessions/<pid>.json, which follows /clear and /resume. That
  -- file isn't a documented interface and appears a moment after Claude
  -- starts, so fall back to a --resume ID on the command line (as restored
  -- panes have), then to the directory's latest conversation.
  claude = function(proc)
    local f = io.open(os.getenv("HOME") .. "/.claude/sessions/" .. proc.pid .. ".json", "r")
    local info = f and rex.json.decode(f:read("*a"))
    if f then
      f:close()
    end
    local id = info and info.sessionId
    if not id then
      local r = rex.exec({ "/bin/ps", "-o", "args=", "-p", tostring(proc.pid) }, { timeout = 2 })
      id = r and r.ok and r.stdout:match("%-%-resume[%s=]+([%x%-]+)")
    end
    if type(id) == "string" and id:match("^[%x%-]+$") then
      return "claude --resume " .. id
    end
    return "claude --continue"
  end,
  -- Pi keeps no record of which session a process has open, so the extension
  -- ~/.pi/agent/extensions/rex-session-file.ts writes one to
  -- ~/.pi/agent/rex-sessions/<pid>.json, following /new, /resume, and /fork.
  -- Pi only writes a session file once it holds a message, so a Pi with no
  -- conversation yet comes back fresh. Without a record (a Pi started before
  -- the extension), fall back to a --session on the command line, then to the
  -- directory's latest session.
  pi = function(proc)
    local agent_dir = os.getenv("PI_CODING_AGENT_DIR") or (os.getenv("HOME") .. "/.pi/agent")
    local f = io.open(agent_dir .. "/rex-sessions/" .. proc.pid .. ".json", "r")
    local info = f and rex.json.decode(f:read("*a"))
    if f then
      f:close()
    end
    local session = info and info.sessionFile
    if type(session) == "string" then
      local saved = io.open(session, "r")
      if not saved then
        return "pi"
      end
      saved:close()
      -- The restore types this into a shell, so only pass a path that needs
      -- no quoting, else the session's ID.
      if not session:match("^[%w%-%._/]+$") then
        session = info.sessionId
      end
    else
      local r = rex.exec({ "/bin/ps", "-o", "args=", "-p", tostring(proc.pid) }, { timeout = 2 })
      session = r and r.ok and r.stdout:match("%-%-session[%s=]+(%S+)")
    end
    if type(session) == "string" and session:match("^[%w%-%._/]+$") then
      return "pi --session " .. session
    end
    return "pi --continue"
  end,
}

local shells = { zsh = true, bash = true, fish = true, sh = true }

-- Helpers ---------------------------------------------------------------------

local function program_name(proc)
  local name = (proc.argv0 or proc.name or ""):match("[^/]+$") or ""
  return (name:gsub("^%-", "")) -- login shells start with a dash
end

local function exists(path)
  local f = path and io.open(path, "r")
  if f then
    f:close()
  end
  return f ~= nil
end

local function read_json(path)
  local f = io.open(path, "r")
  if not f then
    return nil
  end
  local text = f:read("*a")
  f:close()
  return rex.json.decode(text)
end

-- Write through a temporary file and rename it into place, so a crash
-- mid-write leaves the old file rather than half of a new one.
local function write_json(path, value)
  local text = assert(rex.json.encode(value, { indent = true }))
  local tmp = path .. "." .. tostring({}):match("%x+$") .. ".tmp"
  local f = assert(io.open(tmp, "w"))
  f:write(text, "\n")
  f:close()
  assert(os.rename(tmp, path))
end

-- A connection can only read or change sessions it is attached to, and starts
-- out attached to its own. Attaching adds a session without dropping others.
local function attach(session_id)
  return rex.call("session.attach", { session_id = session_id })
end

local function history_files()
  local r = rex.exec({ "/bin/ls", history_dir })
  local files = {}
  for name in ((r and r.ok and r.stdout) or ""):gmatch("[^\n]+") do
    if name:match("^sessions%-%d+%-%d+%.json$") then
      table.insert(files, name)
    end
  end
  table.sort(files) -- the names sort oldest first
  return files
end

local function add_to_history(snapshot)
  local name = os.date("sessions-%Y%m%d-%H%M%S.json", snapshot.saved_at)
  write_json(history_dir .. "/" .. name, snapshot)
  local files = history_files()
  for i = 1, #files - history_keep do
    os.remove(history_dir .. "/" .. files[i])
  end
end

-- The newest snapshot that can still be read: latest.json, or the newest
-- history copy if latest.json was lost or cut short.
local function load_snapshot()
  local snapshot = read_json(latest_path)
  if snapshot and snapshot.version == 1 then
    return snapshot, latest_path
  end
  local files = history_files()
  for i = #files, 1, -1 do
    local path = history_dir .. "/" .. files[i]
    snapshot = read_json(path)
    if snapshot and snapshot.version == 1 then
      return snapshot, path
    end
  end
end

-- Saving ----------------------------------------------------------------------

-- A pane's directory is its shell's, since that's where you land when the
-- program in front of it quits. The program to start again is the one the
-- shell is running, which may itself have started the foreground process
-- (nvim opened from yazi restores as yazi).
local function inspect_pane(session_id, block_id)
  local proc = rex.block.call(terminal, "process", { session_id = session_id, block_id = block_id })
  if not (proc and proc.foreground) then
    return {}
  end
  local chain = { proc.foreground }
  for _, a in ipairs(proc.ancestors or {}) do
    table.insert(chain, a)
  end
  local shell_at
  for i = #chain, 1, -1 do
    if shells[program_name(chain[i])] then
      shell_at = i
      break
    end
  end
  if not shell_at then
    return { cwd = proc.foreground.cwd }
  end
  local pane = { cwd = chain[shell_at].cwd or proc.foreground.cwd }
  local program = chain[shell_at - 1]
  local rule = program and programs[program_name(program)]
  if rule == true then
    local r = rex.exec({ "/bin/ps", "-o", "args=", "-p", tostring(program.pid) }, { timeout = 2 })
    local line = r and r.ok and r.stdout:gsub("%s+$", "")
    -- ps drops the original quoting, so only repeat arguments that need none.
    if line and line ~= "" and not line:find("[^%w%s%./_=:,+@%-]") then
      pane.command = line
    else
      pane.command = program_name(program)
    end
  elseif type(rule) == "string" then
    pane.command = rule
  elseif type(rule) == "function" then
    pane.command = rule(program)
  end
  return pane
end

local function save_layout(node, session_id, blocks, window)
  if node.split then
    local s = node.split
    return {
      split = {
        direction = s.direction,
        ratio = s.ratio,
        before = save_layout(s.before, session_id, blocks, window),
        after = save_layout(s.after, session_id, blocks, window),
      },
    }
  end
  local block = blocks[node.block_id] or {}
  local pane = {}
  if block.creator_name == terminal then
    pane = inspect_pane(session_id, node.block_id)
  end
  pane.label = block.label
  pane.focused = node.block_id == window.focused_block_id or nil
  pane.zoomed = node.block_id == window.zoomed_block_id or nil
  return { pane = pane }
end

local function save_session(session_id)
  attach(session_id)
  local view = assert(rex.session.view{ session_id = session_id })
  local windows = {}
  for _, window in ipairs(view.windows or {}) do
    local saved = { label = window.label, active = window.window_id == view.active_window_id or nil, layers = {} }
    for _, layer in ipairs(window.layers or {}) do
      if layer.layout then
        local blocks = {}
        for _, b in ipairs(layer.blocks or {}) do
          blocks[b.block_id] = b
        end
        table.insert(saved.layers, {
          kind = layer.kind,
          bounds = layer.bounds,
          layout = save_layout(layer.layout, session_id, blocks, window),
        })
      end
    end
    if saved.layers[1] then
      table.insert(windows, saved)
    end
  end
  return { label = view.label, windows = windows }, view.revision
end

-- Read every session, retrying if one changes while it is being read.
local function capture()
  for _ = 1, 3 do
    local list = assert(rex.call("session.list"))
    local sessions, stable = {}, true
    for _, s in ipairs(list.sessions or {}) do
      local saved, revision = save_session(s.session_id)
      local now = rex.session.view{ session_id = s.session_id }
      if not now or now.revision ~= revision then
        stable = false
        break
      end
      table.insert(sessions, saved)
    end
    if stable then
      return sessions
    end
  end
  error("sessions kept changing while being saved; try again", 0)
end

local function save(mode)
  local server = assert(rex.call("server.status"))
  local previous = load_snapshot()
  if mode == "auto" and previous and previous.server ~= server.instance_id then
    return { saved = false, reason = "the snapshot is from before Rex restarted; restore or save by hand first" }
  end

  local snapshot = { version = 1, server = server.instance_id, saved_at = os.time(), sessions = capture() }
  if previous and rex.json.encode(previous.sessions) == rex.json.encode(snapshot.sessions) then
    return { saved = false, reason = "nothing changed" }
  end

  rex.exec({ "/bin/mkdir", "-p", history_dir })
  -- Keep what was open before a restart even if it is never restored.
  if previous and previous.server ~= server.instance_id then
    add_to_history(previous)
  end
  write_json(latest_path, snapshot)
  local files = history_files()
  local newest = files[#files]
  if not newest or newest < os.date("sessions-%Y%m%d-%H%M%S.json", snapshot.saved_at - history_every) then
    add_to_history(snapshot)
  end
  return { saved = true, sessions = #snapshot.sessions, path = latest_path }
end

-- Restoring -------------------------------------------------------------------

local function build_layout(node)
  if node.split then
    local s = node.split
    local make = s.direction == "vertical" and rex.layout.vertical or rex.layout.horizontal
    return make(s.ratio, build_layout(s.before), build_layout(s.after))
  end
  local pane = node.pane
  local options = { cwd = exists(pane.cwd) and pane.cwd or home }
  if pane.command and options.cwd == pane.cwd then
    options.initial_input = pane.command .. "\n"
  end
  return rex.layout.block{ flavor = shell_flavor, options = options }
end

-- Panes in layout order, matching the order block IDs come back in.
local function panes_in_order(node, out)
  out = out or {}
  if node.split then
    panes_in_order(node.split.before, out)
    panes_in_order(node.split.after, out)
  else
    table.insert(out, node.pane or node.block_id)
  end
  return out
end

-- Labels, floating layers, focus, and zoom, applied once the session exists.
local function finish_session(session_id, saved)
  local view = assert(rex.session.view{ session_id = session_id })
  local active
  for i, window in ipairs(view.windows or {}) do
    local saved_window = saved.windows[i]
    local window_id = window.window_id
    for j = 2, #saved_window.layers do
      local layer = saved_window.layers[j]
      rex.session.new_layer{
        session_id = session_id,
        window_id = window_id,
        bounds = layer.bounds,
        layout = build_layout(layer.layout),
        focus = false,
      }
    end
    window = assert(rex.session.view{ session_id = session_id }).windows[i]
    for j, layer in ipairs(window.layers or {}) do
      local ids = layer.layout and panes_in_order(layer.layout) or {}
      local panes = saved_window.layers[j] and panes_in_order(saved_window.layers[j].layout) or {}
      local labels = {}
      for _, b in ipairs(layer.blocks or {}) do
        labels[b.block_id] = b.label
      end
      for k, block_id in ipairs(ids) do
        local pane = panes[k] or {}
        if pane.label and pane.label ~= labels[block_id] then
          rex.session.set_block_label{ session_id = session_id, block_id = block_id, label = pane.label }
        end
        if pane.focused then
          rex.session.focus_block{ session_id = session_id, block_id = block_id }
        end
        if pane.zoomed then
          rex.session.zoom_block{ session_id = session_id, block_id = block_id, zoom = true }
        end
      end
    end
    if saved_window.active then
      active = window_id
    end
  end
  if active then
    rex.session.focus_window{ session_id = session_id, window_id = active }
  end
end

-- An untouched session: one window with one pane sitting at a shell prompt,
-- such as the one Rex starts with after a reboot.
local function is_blank(session_id)
  attach(session_id)
  local view = rex.session.view{ session_id = session_id }
  local windows = view and view.windows or {}
  if #windows ~= 1 or #windows[1].layers ~= 1 then
    return false
  end
  local blocks = windows[1].layers[1].blocks or {}
  if #blocks ~= 1 or blocks[1].creator_name ~= terminal then
    return false
  end
  local proc = rex.block.call(terminal, "process", { session_id = session_id, block_id = blocks[1].block_id })
  return proc ~= nil and proc.foreground ~= nil and shells[program_name(proc.foreground)] == true
end

local function restore(ctx)
  local snapshot, path = load_snapshot()
  if not snapshot then
    error("no saved sessions in " .. state_dir, 0)
  end

  local existing = {}
  for _, s in ipairs(assert(rex.call("session.list")).sessions or {}) do
    existing[s.label] = s.session_id
  end

  local created, skipped = {}, {}
  local ok, err = pcall(function()
    for _, saved in ipairs(snapshot.sessions) do
      if existing[saved.label] then
        table.insert(skipped, saved.label)
      else
        local windows = {}
        for _, w in ipairs(saved.windows) do
          table.insert(windows, { window_label = w.label, layout = build_layout(w.layers[1].layout) })
        end
        local result = assert(rex.call("session.create", { label = saved.label, initial_windows = windows }))
        table.insert(created, { id = result.session_id, saved = saved })
        attach(result.session_id)
      end
    end
  end)
  if not ok then
    -- Leave things as they were rather than half restored.
    for _, c in ipairs(created) do
      rex.call("session.destroy", { session_id = c.id })
    end
    error(err, 0)
  end

  local problems = {}
  for _, c in ipairs(created) do
    local done, why = pcall(finish_session, c.id, c.saved)
    if not done then
      table.insert(problems, c.saved.label .. ": " .. tostring(why))
    end
  end

  -- Close blank sessions that weren't in the snapshot, such as the one Rex
  -- starts with, now that the saved ones are back. The one this ran from
  -- goes last.
  local closed = {}
  if #created > 0 then
    local blank = {}
    for label, id in pairs(existing) do
      if is_blank(id) then
        table.insert(blank, { label = label, id = id })
      end
    end
    table.sort(blank, function(a, b) return (b.id == ctx.session_id) and a.id ~= ctx.session_id end)
    for _, s in ipairs(blank) do
      if rex.call("session.destroy", { session_id = s.id }) then
        table.insert(closed, s.label)
      end
    end
  end

  -- Take ownership of the snapshot so automatic saves resume.
  save("manual")

  return { restored = #created, skipped = skipped, closed = closed, problems = problems, from = path }
end

-- Actions ---------------------------------------------------------------------

rex.action{
  name = "sessions_save",
  title = "Save Sessions",
  description = "Save every session's windows, layouts, and directories so they can be restored after a restart.",
  category = "Session",
  keywords = "snapshot persist resurrect backup",
  args = { mode = "string?" },
  run = function(ctx, args)
    return save(args and args.mode or "manual")
  end,
}

rex.action{
  name = "sessions_restore",
  title = "Restore Sessions",
  description = "Recreate the sessions from the last snapshot that aren't open now.",
  category = "Session",
  keywords = "snapshot persist resurrect reboot restart",
  run = restore,
}
