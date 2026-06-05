return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
  },

  {
    "rebelot/kanagawa.nvim",
    priority = 900,
  },

  {
    "vague-theme/vague.nvim",
    priority = 900,
  },

  {
    "bluz71/vim-moonfly-colors",
    priority = 900,
  },

  {
    "AlexvZyl/nordic.nvim",
    priority = 900,
  },

  {
    "neanias/everforest-nvim",
    priority = 900,
  },

  {
    "zaldih/themery.nvim",
    lazy = false,
    config = function()
      require("themery").setup({
        themes = {
          "catppuccin-frappe",
          "kanagawa",
          "vague",
          "moonfly",
          "nordic",
          "everforest",
        },
        livePreview = true,
      })
    end,
  },
}
