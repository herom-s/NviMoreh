return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = "ToggleTerm", -- lazy-load on command
    keys = {
      { "<F4>", "<cmd>ToggleTerm<cr>", desc = "Toggle floating terminal" },
    },
    config = function()
      require("toggleterm").setup{
        size = 20,
        open_mapping = [[<c-\>]],
        shade_terminals = true,
        start_in_insert = true,
        persist_size = true,
        direction = "float",  -- floating terminal
      }
    end,
  },
}
