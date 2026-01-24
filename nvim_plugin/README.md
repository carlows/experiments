# hello-nvim

A basic "Hello World" Neovim plugin for learning purposes.

## Installation with lazy.nvim

Add this to your Neovim configuration:

```lua
{
  dir = "/Users/carlosmartinez/Documents/personal/experiments/nvim_plugin",
  name = "hello-nvim",
  config = function()
    require("hello-nvim").setup({
      greeting = "Custom Hello!", -- Optional
    })
  end,
}
```

## Usage

Run the following command in Neovim:

```vim
:Hello
```
