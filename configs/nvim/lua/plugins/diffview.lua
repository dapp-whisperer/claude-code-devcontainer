return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    opts = {
      watch_index = true, -- auto-refresh when git index changes
      file_panel = {
        flatten_dirs = true, -- collapse single-child directories (like VS Code)
      },
    },
  },
}
