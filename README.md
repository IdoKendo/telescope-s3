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

Coming soon!

## Roadmap

- [ ] Writing objects
- [ ] Gzip objects

And maybe more?
