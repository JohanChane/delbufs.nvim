# delbufs.nvim

## Installation

1.  Clone it or fork-clone it.
2.  Use a plugin manager to install. For example, with `lazy.nvim`:

    ```lua
    {
      dir = '~/.config/nvim/lua/delbufs.nvim', -- Your clone path of `delbufs.nvim`.
      --'JohanChane/delbufs.nvim',               -- OR
      config = function()
        require('delbufs').setup {             -- See detail. `config.lua`
          --disable_default_keymaps = false,
        }
      end
    },
    ```
