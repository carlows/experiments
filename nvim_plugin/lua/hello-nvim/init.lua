local M = {}

-- This is a simple configuration table that users can eventually override
M.config = {
	greeting = "Hello from your own Neovim plugin!",
}

-- The 'setup' function is a standard convention in Neovim plugins
-- It allows users to pass a table to customize the plugin's behavior
function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

function M.say_hello()
	print(M.config.greeting)
end

function M.add_timestamp()
	local comment_string = vim.bo.commentstring
	if comment_string == "" then
		comment_string = "-- %s" -- default fallback
	end

	local timestamp = os.date("%Y-%m-%d %H:%M:%S")
	local text = comment_string:format("Last modified: " .. timestamp)

	-- nvim_put inserts text at cursor.
	-- {text} is a list of lines, "l" means line-wise, true, true are for following/after
	vim.api.nvim_put({ text }, "l", true, true)
end

function M.show_selection()
  -- Read text from the current visual selection
  local s = vim.fn.getpos("'<")
  local e = vim.fn.getpos("'>")

  if s[2] == 0 or e[2] == 0 then
    print("No selection found!")
    return
  end

  local lines = vim.fn.getregion(s, e, { type = vim.fn.visualmode() })

	-- Create a new empty buffer for the floating window
	local stats_buf = vim.api.nvim_create_buf(false, true) -- No file, scratch buffer
	vim.api.nvim_buf_set_lines(stats_buf, 0, -1, false, lines)

	-- Window dimensions
	local width = 40
	local height = #lines

	-- UI dimensions
	local ui = vim.api.nvim_list_uis()[1]
	local row = math.floor((ui.height - height) / 2)
	local col = math.floor((ui.width - width) / 2)

	-- Create the floating window
	local win = vim.api.nvim_open_win(stats_buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		title = " Current Selection ",
		title_pos = "center",
	})

	-- Make the buffer read-only and add a close mapping
	vim.bo[stats_buf].modifiable = false
	vim.bo[stats_buf].buftype = "nofile"
	vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(win, true)
	end, { buffer = stats_buf, silent = true })
end

return M
