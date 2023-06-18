local actions_state
if pcall(require, "telescope") then
   actions_state = require "telescope.actions.state"
else
   error "Cannot find telescope!"
end
local M = {}
function M.exit_terminal(prompt_bufnr)
   local selection = actions_state.get_selected_entry()
   if selection == nil then
      return
   end
   local bufnr = selection.value.bufnr
   local current_picker = actions_state.get_current_picker(prompt_bufnr)
   current_picker:delete_selection(function(selection)
      vim.api.nvim_buf_delete(bufnr, { force = true })
   end)
end
return M
