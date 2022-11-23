-- formatting
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = { "*.go" },
  callback = vim.lsp.buf.format,
})

-- goimports
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.go',
  callback = function ()
    local params = vim.lsp.util.make_range_params()
    params.context = {only = {"source.organizeImports"}}
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 5000)
    for cid, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
          vim.lsp.util.apply_workspace_edit(r.edit, enc) 
        else
          vim.lsp.buf.execute_command(r.command)
        end
      end
    end
  end,
})

