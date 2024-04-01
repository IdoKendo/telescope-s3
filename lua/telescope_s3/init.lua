local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")
local config = require("telescope.config").values
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")

local M = {}

local function ft(key)
    local parts = {}
    for part in string.gmatch(key, "[^%.]+") do
        parts[#parts + 1] = part
    end
    return parts[#parts]
end

local run = function(command)
    local handle = io.popen(command)
    if handle == nil then
        vim.notify("could not run command " .. command)
        return nil
    end

    local result = handle:read("*a")
    handle:close()
    return result
end

local list_objects = function(opts, bucket)
    local cmd = {
        "aws",
        "s3api",
        "list-objects",
        "--bucket",
        bucket,
        "--query",
        '"Contents[].{key:Key}"',
    }
    local results = run(vim.fn.join(cmd, " "))
    if results == nil then
        vim.notify("No objects in s3://" .. bucket)
        return
    end
    results = vim.fn.json_decode(results)

    pickers
        .new(opts, {
            finder = finders.new_table({
                results = results,

                entry_maker = function(entry)
                    return {
                        value = entry,
                        display = entry.key,
                        ordinal = entry.key,
                    }
                end,
            }),

            attach_mappings = function(prompt_bufnr)
                actions.select_default:replace(function()
                    local selection = action_state.get_selected_entry()
                    local out = { os.tmpname(), ft(selection.value.key) }
                    out = vim.fn.join(out, ".")
                    actions.close(prompt_bufnr)
                    cmd = {
                        "aws",
                        "s3api",
                        "get-object",
                        "--bucket",
                        bucket,
                        "--key",
                        selection.value.key,
                        out,
                    }
                    run(vim.fn.join(cmd, " "))
                    vim.cmd("edit " .. out)
                end)
                return true
            end,
        })
        :find()
end

M.read_object = function(opts)
    local cmd = {
        "aws",
        "s3api",
        "list-buckets",
        "--query",
        '"Buckets[].{name:Name}"',
    }
    local results = run(vim.fn.join(cmd, " "))
    if results == nil then
        return
    end
    results = vim.fn.json_decode(results)

    pickers
        .new(opts, {
            finder = finders.new_table({
                results = results,

                entry_maker = function(entry)
                    return {
                        display = entry.name,
                        ordinal = entry.name,
                    }
                end,
            }),

            sorter = config.generic_sorter(opts),

            attach_mappings = function(prompt_bufnr)
                actions.select_default:replace(function()
                    local selection = action_state.get_selected_entry()
                    actions.close(prompt_bufnr)
                    list_objects(opts, selection.display)
                end)
                return true
            end,
        })
        :find()
end

return M
