local telescope_s3 = require("telescope_s3")

return require("telescope").register_extension({
    exports = {
        delete_object = telescope_s3.delete_object,
        read_object = telescope_s3.read_object,
        write_object = telescope_s3.write_object,
    },
})
