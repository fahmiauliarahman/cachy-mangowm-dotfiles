return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    opts = {
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "blade-nav" },
        providers = {
          ["blade-nav"] = {
            name = "blade-nav",
            module = "blade-nav.integrations.blink",
          },
        },
      },
    },
  },
  {
    "folke/noice.nvim",
    opts = {
      lsp = {
        signature = {
          opts = {
            size = { max_width = 80, max_height = 12 },
          },
        },
      },
    },
  },
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          files = { hidden = true, ignored = true },
          explorer = {
            layout = { layout = { position = "right" } },
          },
        },
      },
    },
  },
}
