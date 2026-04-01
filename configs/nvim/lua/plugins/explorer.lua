return {
  -- Disable neo-tree in favour of snacks explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = false,
  },
  -- Snacks explorer with hidden and gitignored files visible by default
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          files = {
            hidden = true,
            ignored = true,
          },
          explorer = {
            hidden = true,
            ignored = true,
            win = {
              list = {
                keys = {
                  ["c"] = { "explorer_yank", mode = { "n", "x" } },
                  ["C"] = "explorer_copy",
                },
              },
            },
          },
        },
      },
    },
  },
}
