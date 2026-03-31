return {
  {
    "chomosuke/mermaid-preview.nvim",
    cmd = { "MermaidPreview", "MermaidPreviewToggle" },
    opts = {
      -- Utilise le renderer mmdc que tu as déjà dans Mason
      output = "kitty", -- Rend directement dans kitty !
    },
    keys = {
      { "<leader>mp", "<cmd>MermaidPreview<cr>", desc = "Mermaid Preview" },
    },
  },
}