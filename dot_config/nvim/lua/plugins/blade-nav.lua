return {
  {
    "ricardoramirezr/blade-nav.nvim",
    ft = { "blade", "php" },
    opts = {
      integrations = {
        cmp = false,
        coq = false,
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "blade", "php", "vue", "html" },
    },
  },
}
