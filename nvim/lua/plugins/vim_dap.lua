return {
	"mfussenegger/nvim-dap",
	dependencies = {
        "igorlfs/nvim-dap-view",
        "theHamsta/nvim-dap-virtual-text",
        "mfussenegger/nvim-dap-python"
    },
	config = function()

		local dap = require("dap")
        require('dap-python').setup()

        require("nvim-dap-virtual-text").setup()

        local dapview = require("dap-view")
        dapview.setup() -- Ensure dap-view is set up

        -- Autocmd to open dap-view automatically when a debugging session is initiated
        dap.listeners.before.attach.dapview_config = function()
          dapview.open()
        end
        dap.listeners.before.launch.dapview_config = function()
          dapview.open()
        end

        -- Optional: Autocmd to close dap-view automatically when the session terminates or exits
        dap.listeners.before.event_terminated.dapview_config = function()
          dapview.close()
        end

        dap.listeners.before.event_exited.dapview_config = function()
          dapview.close()
        end

        dap.listeners.after.event_terminated.dapview_config = function ()
            dapview.close()
        end

        dap.listeners.after.event_exited.dapview_config = function ()
            dapview.close()
        end

        --vim.fn.sign_define('DapBreakpoint', {text='🔴', texthl='', linehl='', numhl=''})
        --vim.fn.sign_define('DapBreakpoint', {text='•', texthl='red', linehl='', numhl=''})
        --
        vim.api.nvim_set_hl(0, "blue",   { fg = "#3d59a1" })
        vim.api.nvim_set_hl(0, "green",  { fg = "#9ece6a" })
        vim.api.nvim_set_hl(0, "yellow", { fg = "#FFFF00" })
        vim.api.nvim_set_hl(0, "orange", { fg = "#f09000" })


        vim.fn.sign_define('DapBreakpoint', { text='🔺', texthl='', linehl='', numhl='' })
        vim.fn.sign_define('DapStopped', { text='', texthl='yellow', linehl='yellow', numhl= 'yellow' })

	end,
}
