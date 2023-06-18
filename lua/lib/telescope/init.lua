local pickers, finders, actions, actions_state, conf
if pcall(require, "telescope") then
   pickers = require "telescope.pickers"
   finders = require "telescope.finders"
   actions = require "telescope.actions"
   actions_state = require "telescope.actions.state"
   conf = require("telescope.config").values
else
   error "Cannot find telescope!"
end
local status_ok, _ = pcall(require, "toggleterm")
if not status_ok then
   error "Cannot find toggleterm!"
end

local function next_id()
   local all = require("toggleterm.terminal").get_all(true)

   for index, term in pairs(all) do
      if index ~= term.id then return index end
   end
   return #all + 1
end


local function toggle_term(bfnr)
   local bufnr = tonumber(bfnr)
   local all_terminals = require("toggleterm.terminal").get_all(true)
   local id = nil
   for _, term in pairs(all_terminals) do
      if term.bufnr == bufnr then
         id = term.id
      end
   end

   if id then
      require("toggleterm").toggle_command(nil, id)
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
      })
      cmdTerm:toggle()
   end
end

local M = {}
M.open = function(opts)
   local bufnrs = vim.tbl_filter(function(b)
      return vim.api.nvim_buf_get_option(b, "filetype") == "toggleterm"
   end, vim.api.nvim_list_bufs())
   -- ╭────────────────────────────────────────────────────────────────────╮
   -- │                                note                                │
   -- ╰────────────────────────────────────────────────────────────────────╯
   -- uncommenting this prevents
   -- telescope from opening a modal windows when there are
   -- no terminal buffers open.
   -- ──────────────────────────────────────────────────────────────────────
   -- if not next(bufnrs) then
   --    return
   -- end
   -- ──────────────────────────────────────────────────────────────────────
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

   -- local terminals = require("toggleterm.terminal").get_all(true)
   -- teminals tabels of objects which contains id and name
   -- create results with id and name
   -- then use the id to toggle the terminal
   -- ──────────────────────────────────────────────────────────────────────
   -- local results = {}
   -- for _, terminal in ipairs(terminals) do
   --    local element = {
   --       id = terminal.id,
   --       name = terminal.name,
   --       bufnr = terminal.bufnr,
   --    }
   --    table.insert(results, element)
   -- end
   -- ──────────────────────────────────────────────────────────────────────
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
         actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = actions_state.get_selected_entry()
            if selection == nil then
               return
            end
            local bufnr = tostring(selection.value.bufnr)
            -- local toggle_number = selection.value.toggle_number
            -- P(selection.value)
            -- P(require("toggleterm.terminal").get_all(true))
            -- P(results)

            -- require("toggleterm").toggle_command(nil, selection.value.id)
            -- require("toggleterm").toggle_command(nil, toggle_number)
            toggle_term(bufnr)
            -- vim.defer_fn(function()
            --    vim.cmd "stopinsert"
            -- end, 0)
         end)
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
