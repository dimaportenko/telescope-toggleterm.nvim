local pickers, finders, actions, conf
if pcall(require, "telescope") then
   pickers = require "telescope.pickers"
   finders = require "telescope.finders"
   actions = require "telescope.actions"
   conf = require("telescope.config").values
else
   error "Cannot find telescope!"
end
local status_ok, _ = pcall(require, "toggleterm")
if not status_ok then
   error "Cannot find toggleterm!"
end

local open_action = require('lib.actions').open

local M = {}
M.open = function(opts)
   local bufnrs = vim.tbl_filter(function(b)
      return vim.api.nvim_buf_get_option(b, "filetype") == "toggleterm"
   end, vim.api.nvim_list_bufs())

   table.sort(bufnrs, function(a, b)
      return vim.fn.getbufinfo(a)[1].lastused > vim.fn.getbufinfo(b)[1].lastused
   end)
   local buffers = {}
   for _, bufnr in ipairs(bufnrs) do
      local info = vim.fn.getbufinfo(bufnr)[1]
      local element = {
         bufnr = info.bufnr,
         changed = info.changed,
         changedtick = info.changedtick,
         hidden = info.hidden,
         lastused = info.lastused,
         linecount = info.linecount,
         listed = info.listed,
         lnum = info.lnum,
         loaded = info.loaded,
         name = info.name,
         windows = info.windows,
         terminal_job_id = info.variables.terminal_job_id,
         terminal_job_pid = info.variables.terminal_job_pid,
         toggle_number = info.variables.toggle_number,
      }
      table.insert(buffers, element)
   end

   pickers.new(opts, {
      prompt_title = "Terminal Buffers",
      finder = finders.new_table {
         -- results = results,
         results = buffers,
         entry_maker = function(entry)
            return {
               value = entry,
               text = tostring(entry.bufnr),
               display = tostring(entry.name),
               ordinal = tostring(entry.bufnr),
            }
         end,
      },
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
         actions.select_default:replace(open_action)

         -- ╭────────────────────────────────────────────────────────────────────╮
         -- │                           setup mappings                           │
         -- ╰────────────────────────────────────────────────────────────────────╯
         local mappings = require("config").options.telescope_mappings
         for keybind, action in pairs(mappings) do
            map("i", keybind, function()
               action(prompt_bufnr)
            end)
         end
         return true
      end,
   }):find()
end
return M
