return {
  -- Ensure treesitter markdown parsers are installed
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed or {}, {
        "markdown",
        "markdown_inline",
        "html",
        "latex",
        "yaml",
      })
    end,
  },

  -- In-buffer markdown rendering
  {
    "OXY2DEV/markview.nvim",
    lazy = false, -- plugin self-manages its loading per its README
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      preview = {
        icon_provider = "mini",
        modes = { "n", "no", "c" },
        hybrid_modes = { "i", "v" },
        linewise_hybrid_mode = true,
        edit_range = { 1, 1 },
      },
    },
    keys = {
      { "<leader>mm", "<cmd>Markview toggle<cr>", desc = "Toggle Markview", ft = "markdown" },
      { "<leader>mh", "<cmd>Markview hybridToggle<cr>", desc = "Toggle hybrid mode", ft = "markdown" },
      { "<leader>ms", "<cmd>Markview splitToggle<cr>", desc = "Toggle split preview", ft = "markdown" },
      {
        "<leader>mw",
        function()
          vim.wo.wrap = not vim.wo.wrap
          vim.notify("wrap " .. (vim.wo.wrap and "on" or "off (tables)"))
        end,
        desc = "Toggle wrap",
        ft = "markdown",
      },
    },
  },
}
