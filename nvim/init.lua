-- This file simply bootstraps the installation of Lazy.nvim and then calls other files for execution
-- This file doesn't necessarily need to be touched, BE CAUTIOUS editing this file and proceed at your own risk.
local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- validate that lazy is available
if not pcall(require, "lazy") then
  -- stylua: ignore
  vim.api.nvim_echo({ { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
  vim.fn.getchar()
  vim.cmd.quit()
end

require "lazy_setup"
require "polish"

-- Rajin settings

-- local Plug = vim.fn["plug#"]

-- vim.call "plug#begin"

-- Plug "towolf/vim-helm"
-- Plug("simnalamburt/vim-tiny-ime", { ["do"] = "./build" })

-- vim.call "plug#end"

vim.api.nvim_set_keymap("v", "<M-p>", "<space>/", { noremap = false })

vim.api.nvim_set_keymap("n", "<M-i>", "]b", { noremap = false })

vim.api.nvim_set_keymap("n", "<M-o>", "[b", { noremap = false })

vim.keymap.set("x", "<leader>ae", function() require("claude_edit").edit_selection() end,
  { desc = "Claude: edit selection (one-shot)" })
