local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")
local config = require("telescope.config").values
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")

local function ft(key)
    local parts = {}
    for part in string.gmatch(key, "[^%.]+") do
        parts[#parts + 1] = part
    end
    return parts[#parts]
end

local function run(command)
    local handle = io.popen(command)
    if handle == nil then
        vim.notify("could not run command " .. command)
        return nil
    end

    local result = handle:read("*a")
    handle:close()
    return result
end

local function get_object(bucket, key)
    local out = { os.tmpname(), ft(key) }
    out = vim.fn.join(out, ".")
    local cmd = {
        "aws",
        "s3api",
        "get-object",
        "--bucket",
        bucket,
        "--key",
        key,
        out,
    }
    run(vim.fn.join(cmd, " "))
    vim.cmd("edit " .. out)
end

local function delete_object(bucket, key)
    local cmd = {
        "aws",
        "s3api",
        "delete-object",
        "--bucket",
        bucket,
        "--key",
        key,
    }
    run(vim.fn.join(cmd, " "))
end

local function list_objects(opts, bucket, handler)
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
                    actions.close(prompt_bufnr)
                    handler(bucket, selection.value.key)
                end)
                return true
            end,
        })
        :find()
end

local function list_buckets()
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
    return vim.fn.json_decode(results)
end

local function put_object(opts, display)
    vim.ui.input({ prompt = "Object key" }, function(res)
        if res == nil then
            return
        end
        local buffer = vim.fn.expand("%:p")
        local suffix = ft(buffer)

        local cmd = {
            "aws",
            "s3",
            "cp",
            buffer,
            "s3://" .. display .. "/" .. res .. "." .. suffix,
        }
        local result = run(vim.fn.join(cmd, " "))
        if result then
            vim.notify(result, vim.log.levels.INFO, opts)
        end
    end)
end

local function find_and_handle_object(opts, handler, handle_objects)
    local results = list_buckets()
    if results == nil then
        return
    end
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
                    if handle_objects then
                        list_objects(opts, selection.display, handler)
                    else
                        handler(opts, selection.display)
                    end
                end)
                return true
            end,
        })
        :find()
end

local M = {}

M.read_object = function(opts)
    find_and_handle_object(opts, get_object, true)
end

M.delete_object = function(opts)
    find_and_handle_object(opts, delete_object, true)
end

M.write_object = function(opts)
    find_and_handle_object(opts, put_object, false)
end

return M
