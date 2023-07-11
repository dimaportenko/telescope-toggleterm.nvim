
local M = {}

local function next_id()
   local all = require("toggleterm.terminal").get_all(true)

   for index, term in pairs(all) do
      if index ~= term.id then return index end
   end
   return #all + 1
end

M.toggle_term = function (bfnr, direction)
   direction = direction or "horizontal"
   local bufnr = tonumber(bfnr)
   local all_terminals = require("toggleterm.terminal").get_all(true)
   local id = nil
   for _, term in pairs(all_terminals) do
      if term.bufnr == bufnr then
         id = term.id
      end
   end

   if id then
      require("toggleterm").toggle(id, nil, nil, direction)
   else
      id = next_id()
      ---@diagnostic disable-next-line: param-type-mismatch
      if vim.api.nvim_buf_is_valid(bufnr) == false then
         error("bufnr is not valid")
      end

      local cmdTerm = require("toggleterm.terminal").Terminal:new({
         id            = id,
         bufnr         = bufnr,
         hidden        = true,
         close_on_exit = false,
         direction     = direction,
      })
      cmdTerm:toggle()
   end
end

return M
