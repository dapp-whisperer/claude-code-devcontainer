-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
-- vim.opt.showbreak = "↪ "
vim.opt.fillchars:append({ diff = " " })

-- Start RPC server for external file-open integration (tmux-fingers, etc.)
local sock = (vim.env.XDG_RUNTIME_DIR or '/tmp') .. '/nvim-server.sock'
pcall(vim.fn.delete, sock)
vim.fn.serverstart(sock)
