local M = {}

local function config_delbufs(opts)
  local delbufs = require('delbufs.delbufs')

  if not opts.disable_default_keymaps then
    vim.keymap.set('n', '<Leader>ba', function()
      local del_bufs = delbufs.del_all_bufs()
      vim.api.nvim_echo({ { string.format('Deleted all buffers (%s)', #del_bufs) } }, false, {})
    end, { noremap = true, desc = 'Close all buffers' })

    vim.keymap.set('n', '<Leader>bo', function()
      local del_bufs = delbufs.del_other_bufs()
      vim.api.nvim_echo({ { string.format('Deleted other buffers (%s)', #del_bufs) } }, false, {})
    end, { noremap = true, desc = 'Close other buffers' })

    vim.keymap.set('n', '<Leader>bh', function()
      local del_bufs = delbufs.del_hidden_bufs()
      vim.api.nvim_echo({ { string.format('Deleted hidden buffers (%s)', #del_bufs) } }, false, {})
    end, { noremap = true, desc = 'Close hidden buffers' })

    vim.keymap.set('n', '<Leader>bb', function()
      local del_bufs = delbufs.del_unused_bufs()
      vim.api.nvim_echo({ { string.format('Deleted unused buffers (%s)', #del_bufs) } }, false, {})
    end, { noremap = true, desc = 'Delete unused buffers' })

    vim.keymap.set('n', '<Leader>bc', function()
      delbufs.confirm_delbufs()
    end, { noremap = true, desc = 'Confirm delbufs' })
  end
end

function M.setup(opts)
  local config = require('delbufs.config')
  config.setup_opts = vim.tbl_deep_extend('force', config.default_opts, opts)

  require('delbufs.delbufs')

  config_delbufs(config.setup_opts)
end

local lazyloaded_modules = {
  del_all_bufs = { 'delbufs.delbufs', 'del_all_bufs' },
  del_other_bufs = { 'delbufs.delbufs', 'del_other_bufs' },
  del_hidden_bufs = { 'delbufs.delbufs', 'del_hidden_bufs' },
  del_unused_bufs = { 'delbufs.delbufs', 'del_unused_bufs' },
  confirm_delbufs = { 'delbufs.delbufs', 'confirm_delbufs' },
}

for k, v in pairs(lazyloaded_modules) do
  M[k] = function(...)
    return require(v[1])[v[2]](...)
  end
end

local exported_modules = {
  'delbufs'
}

for _, m in ipairs(exported_modules) do
  M[m] = function()
    return require('delbufs.' .. m)
  end
end

return M
