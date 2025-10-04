return {
  "sveltejs/language-tools",
  config = function ()
    require("lspconfig").svelte.setup{}
  end
}
