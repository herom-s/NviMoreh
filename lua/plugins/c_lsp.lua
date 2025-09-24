return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      clangd = {
        keys = {
          { "<leader>cR", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
        },
        capabilities = {
          offsetEncoding = { "utf-16" },
        },
        cmd = {
          "clangd",
          "--background-index",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders=true",
        },
        on_new_config = function(new_config, new_root_dir)
          local util = require("lspconfig.util")
          local root_dir = new_root_dir or util.root_pattern("compile_commands.json", ".git")(vim.fn.getcwd()) or vim.fn.getcwd()

          local compile_commands_dir = root_dir .. "/build"

          -- Add compile commands directory if it exists
          if vim.fn.isdirectory(compile_commands_dir) == 1 then
            table.insert(new_config.cmd, "--compile-commands-dir=" .. compile_commands_dir)
          end

          -- Find all directories containing .h or .hpp files
          local function find_header_dirs(dir)
            local header_dirs = {}
            local handle = io.popen("find '" .. dir .. "' -name '*.h' -o -name '*.hpp' 2>/dev/null | xargs -r dirname | sort -u")
            if handle then
              for line in handle:lines() do
                -- Only include directories that are within the project (relative to root_dir)
                if line:find(root_dir, 1, true) == 1 then
                  table.insert(header_dirs, line)
                end
              end
              handle:close()
            end
            return header_dirs
          end

          -- Create or update compile_flags.txt with all header directories
          local compile_flags_file = root_dir .. "/compile_flags.txt"
          local header_dirs = find_header_dirs(root_dir)
          
          if #header_dirs > 0 then
            local flags_content = ""
            for _, dir in ipairs(header_dirs) do
              flags_content = flags_content .. "-I" .. dir .. "\n"
            end
            
            -- Only write if file doesn't exist or if we found new directories
            if vim.fn.filereadable(compile_flags_file) == 0 then
              local file = io.open(compile_flags_file, "w")
              if file then
                file:write(flags_content)
                file:close()
              end
            end
          end
        end,
      },
    },
  },
}
