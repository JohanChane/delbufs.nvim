local function is_excluded(bufnr)
  local is_ex = vim.fn.buflisted(bufnr) == 0
  --or vim.fn.getbufvar(bufnr, '&filetype') == 'qf' -- quickfix
  --or vim.fn.getbufvar(bufnr, '&buftype') == 'terminal'
  return is_ex
end

-- get included buffers
local function get_incl_buf_list()
  local incl_buf_list = {}
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if not is_excluded(bufnr) then
      table.insert(incl_buf_list, bufnr)
    end
  end

  return incl_buf_list
end

local function del_all_bufs()
  local del_bufs = {}
  for _, bufnr in ipairs(get_incl_buf_list()) do
    vim.api.nvim_buf_delete(bufnr, {})
    table.insert(del_bufs, bufnr)
  end

  return del_bufs
end

local function del_other_bufs()
  local del_bufs = {}
  for _, bufnr in ipairs(get_incl_buf_list()) do
    if bufnr ~= vim.api.nvim_get_current_buf() then
      vim.api.nvim_buf_delete(bufnr, {})
      table.insert(del_bufs, bufnr)
    end
  end

  return del_bufs
end

local function del_hidden_bufs()
  local non_hidden_buffer_set = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local bufnr = vim.api.nvim_win_get_buf(win)
    non_hidden_buffer_set[bufnr] = true
  end

  local del_bufs = {}
  for _, bufnr in ipairs(get_incl_buf_list()) do
    if not non_hidden_buffer_set[bufnr] then
      vim.api.nvim_buf_delete(bufnr, {})
      table.insert(del_bufs, bufnr)
    end
  end

  return del_bufs
end

-- ## [Closing unused buffers](https://www.reddit.com/r/neovim/comments/12c4ad8/closing_unused_buffers/)
local augroup_id = vim.api.nvim_create_augroup('delbufs', {
  clear = false
})

local persistbuffer = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  vim.fn.setbufvar(bufnr, 'delbufs_bufpersist', 1)
end

vim.api.nvim_create_autocmd({ 'BufRead' }, {
  group = augroup_id,
  pattern = { '*' },
  callback = function()
    vim.api.nvim_create_autocmd({ 'InsertEnter', 'BufModifiedSet' }, {
      buffer = 0,
      once = true,
      callback = function()
        persistbuffer()
      end
    })
  end
})

local function is_presist_buf(bufnr)
  return vim.fn.getbufvar(bufnr, 'delbufs_bufpersist') == 1
end

local function del_unused_bufs()
  local del_bufs = {}
  local curbufnr = vim.api.nvim_get_current_buf()
  for _, bufnr in ipairs(get_incl_buf_list()) do
    if bufnr ~= curbufnr and not is_presist_buf(bufnr) then
      vim.api.nvim_buf_delete(bufnr, {})
      table.insert(del_bufs, bufnr)
    end
  end

  return del_bufs
end

-- ## confirm menu
local function confirm_delbufs()
  local choice = vim.fn.confirm('Delete buffers:', '&Unused\n&Hidden\n&Others\n&All', 0)
  local choice_options = { 'unused', 'hidden', 'others', 'all' }
  local del_bufs
  if choice == 1 then
    del_bufs = del_unused_bufs()
  elseif choice == 2 then
    del_bufs = del_hidden_bufs()
  elseif choice == 3 then
    del_bufs = del_other_bufs()
  elseif choice == 4 then
    del_bufs = del_all_bufs()
  end

  if del_bufs then
    vim.api.nvim_echo({ { string.format('Deleted %s buffers (%s)', choice_options[choice], #del_bufs) } }, false, {})
  end
end

return {
  del_all_bufs = del_all_bufs,
  del_other_bufs = del_other_bufs,
  del_hidden_bufs = del_hidden_bufs,
  del_unused_bufs = del_unused_bufs,
  confirm_delbufs = confirm_delbufs
}
