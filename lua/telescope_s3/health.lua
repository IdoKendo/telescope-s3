local health = vim.health or require("health")

local M = {}

M.check = function()
    health.start("Checking...")
    if vim.fn.executable("aws") == 1 then
        health.ok("AWS CLI is installed.")
    else
        health.error("AWS CLI not found.")
    end
end

return M
