-- Create a user command called :Hello
-- This command will trigger the say_hello function from our module
vim.api.nvim_create_user_command('Hello', function()
  require('hello-nvim').say_hello()
end, { desc = "Prints a greeting from the hello-nvim plugin" })

vim.api.nvim_create_user_command('HelloTimestamp', function()
  require('hello-nvim').add_timestamp()
end, { desc = "Adds a timestamp comment below the current line" })

vim.api.nvim_create_user_command('OpenInChrome', function()
  require('hello-nvim').open_in_chrome()
end, { desc = "Opens the current file in chrome" })

vim.api.nvim_create_user_command('HelloSelection', function()
  require('hello-nvim').show_selection()
end, { range = true, desc = "Shows the current selection in a buffer window" })

-- Reload command for easy development
vim.api.nvim_create_user_command('HelloReload', function()
  -- Clear the lua cache
  package.loaded['hello-nvim'] = nil
  
  -- Get the path of the current file and source it
  local str = debug.getinfo(1).source:sub(2)
  vim.cmd('source ' .. str)
  
  print("Hello-Nvim: Reloaded!")
end, { desc = "Reloads the plugin logic without restarting Neovim" })

-- Example Keybinding: <leader>hr to reload
vim.keymap.set('n', '<leader>hr', ':HelloReload<CR>', { silent = true, desc = "Reload Hello-Nvim" })


