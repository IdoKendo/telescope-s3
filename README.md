# Telescope-S3

## Installation
Using lazy.nvim:
```lua
{
    "IdoKendo/telescope-s3",
    event = "VeryLazy",
    dependencies = {
        "nvim-telescope/telescope.nvim",
    },
    config = function()
        require("telescope").load_extension("telescope_s3")
    end,
    keys = {
        { "<leader>s3r", ":Telescope telescope_s3 read_object<CR>", desc = "[S3] [R]ead" },
        { "<leader>s3w", ":Telescope telescope_s3 write_object<CR>", desc = "[S3] [W]rite" },
    },
}
```
## Dependencies
- [AWS CLI](https://github.com/aws/aws-cli) installed and in `$PATH`
- Neovim 0.8+

Run a health check after configuring: `:checkhealth telescope-s3` 

## Usage

### Read object

You can run `:Telescope telescope_s3 read_object` or use the above keymap `<leader>s3r`
which will open a telescope selector for buckets, after selecting the bucket it will open
a new telescope selector for the objects in the bucket, selecting it will download the
file to a temp location and will open in a new buffer.

### Write object

Toy can run `:Telescope telescope_s3 write_object` or use the above keypmap `<leader>s3w`
which will open a telescope selector for buckets, after selecting the bucket it will open
an input to insert the key to which the current buffer will be uploaded to in the bucket.
Note that you can use partitioning here, e.g. if you selected a bucket `plugins` and the
key will be `nvim/lua/telescope.lua` then the eventual S3 path will be:
`s3://plugins/nvim/lua/telescope.lua`.

## Roadmap

- [ ] Deleting objects
- [ ] Gzip objects

And maybe more?
