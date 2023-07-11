local M = {}

local defaults = {
    -- Key mappings bound inside the telescope window
    telescope_mappings = {
        ['<C-c>'] = require('lib.actions').exit_terminal,
        ['<C-f>'] = require('lib.actions').open_float,
    }
}
M.options = {}
function M.setup(opts)
    opts = opts or {}
    M.options = vim.tbl_deep_extend("force", defaults, opts)
end
M.setup()
return M
