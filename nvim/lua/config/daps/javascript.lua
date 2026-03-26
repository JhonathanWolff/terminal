
local dap =require("dap")

dap.adapters["pwa-node"] = {
    type = "server",
    host = "localhost",
    port = "${port}",
    executable = {
        -- installed via manson
        command = "js-debug-adapter",
        args = {"${port}" },
    }
}

local js_languages = {
"javascript",
"typescript",
"vue"
}

for _,language in ipairs(js_languages) do

    dap.configurations[language] = {
      {
        type = "pwa-node",
        request = "launch",
        name = "Launch file",
        program = "${file}",
        cwd = "${workspaceFolder}",
      },
    }

end


