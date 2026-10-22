-- Pane-level keys live here so they work the same in every pane. Programs
-- keep the keys that are about them.

local terminal = "com.superlogical.terminal"
local home = os.getenv("HOME")

-- The server runs with the bare system PATH, so programs started from here
-- get these first. Missing directories are harmless.
local bin_path = {
  home .. "/bin",
  home .. "/.cargo/bin",
  home .. "/.local/bin",
  home .. "/.local/share/mise/shims",
  "/opt/homebrew/bin",
  "/usr/local/bin",
}

local function foreground(block_id)
  local p = rex.block.call(terminal, "process", { block_id = block_id }) or {}
  return p.foreground or {}
end

-- The directory the block last reported (OSC 7), else its foreground program's.
local function cwd(block_id)
  local pwd = (rex.block.call(terminal, "pwd", { block_id = block_id }) or {}).pwd
  return pwd and (pwd:gsub("^file://[^/]*", "")) or foreground(block_id).cwd
end

-- Binds key to fn, except in plain nvim, which has splits and a tree of its
-- own and hands off at their edges (plugin/keymaps.lua).
local function bind_outside_nvim(key, fn)
  rex.bind(key, function(ctx)
    if foreground(ctx.block_id).name == "nvim" then
      return false
    end
    fn(ctx)
    return true
  end)
end

-- Ctrl-hjkl moves between panes.
for key, dir in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  bind_outside_nvim("ctrl+" .. key, function()
    rex.session.focus_direction({ direction = dir })
  end)
end

-- Ctrl-n toggles yazi as a file tree left of the focused pane; see
-- ~/.config/yazi-tree (tmux-toggle.sh is the tmux counterpart).
rex.action({
  name = "files",
  title = "Toggle File Tree",
  description = "Open yazi on the left of the focused pane, or close it.",
  run = function(ctx)
    local blocks = (rex.session.list_blocks({}) or {}).blocks or {}
    local window
    for _, b in ipairs(blocks) do
      if b.block_id == ctx.block_id then
        window = b.window_id
      end
    end
    for _, b in ipairs(blocks) do
      if b.label == "files" and b.window_id == window then
        return rex.call("block.close", { session_id = ctx.session_id, block_id = b.block_id })
      end
    end

    local command = { home .. "/.config/yazi-tree/start.sh" }
    if foreground(ctx.block_id).name == "mxvim" then
      table.insert(command, "--mxvim")
    end
    local split, err = rex.session.new_split({
      anchor_id = ctx.block_id,
      direction = "horizontal",
      side = "before",
      ratio = 0.2,
      focus = true,
      layout = rex.layout.block({
        flavor = terminal .. ".shell",
        options = { command = command, cwd = cwd(ctx.block_id), path_prepend = bin_path },
      }),
    })
    if not split then
      return rex.log("error", "files: " .. tostring(err))
    end
    rex.session.set_block_label({ block_id = split.block_ids[1], label = "files" })
  end,
})
bind_outside_nvim("ctrl+n", function()
  rex.invoke("files")
end)

-- re (~/bin/re) from the focused pane's directory, with the keys from
-- ~/.tmux.conf behind a Ctrl-Space prefix.
local re_env = {
  PATH = table.concat(bin_path, ":") .. ":/usr/bin:/bin:/usr/sbin:/sbin",
  EDITOR = "nvim", -- the server has none; `re edit` wants (n)vim
}
-- The server doesn't set REX_BIN_DIR for itself; on macOS the CLI lives in
-- the app bundle ("Current" follows updates). Elsewhere it's on PATH.
local mac_rex = home
  .. "/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS"
local f = io.open(mac_rex .. "/rex")
if f then
  f:close()
  re_env.REX_BIN_DIR = mac_rex
end

rex.action({
  name = "re",
  title = "re",
  description = "Run re in the focused pane's directory, with these arguments.",
  args = { args = "array?" },
  run = function(ctx, a)
    local argv = { home .. "/bin/re", "-C", cwd(ctx.block_id) }
    for _, arg in ipairs(a.args or {}) do
      table.insert(argv, arg)
    end
    local env = { REX_SESSION = ctx.session_id, REX_BLOCK = ctx.block_id }
    for k, v in pairs(re_env) do
      env[k] = v
    end
    local _, err = rex.exec.start(argv, {
      env = env,
      detach = true,
      stdout = false,
      stderr = function(out)
        rex.log("error", "re: " .. out)
      end,
    })
    if err then
      rex.log("error", "re: " .. err)
    end
  end,
})

for key, n in pairs({ n = "1", m = "2", [","] = "3", ["."] = "4" }) do
  rex.bind("ctrl+space>" .. key, "re", { args = { n } })
end
rex.bind("ctrl+space>space", "re") -- the picker
rex.bind("ctrl+space>ctrl+space", "re")
rex.bind("ctrl+d", "re", { args = { "edit" } })
