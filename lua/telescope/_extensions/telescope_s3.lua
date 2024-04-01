local telescope_s3 = require("telescope_s3")

return require("telescope").register_extension({
    exports = {
        read_object = telescope_s3.read_object,
    },
})
