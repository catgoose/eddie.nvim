# eddie

<!--toc:start-->

- [eddie](#eddie)
  - [Usage](#usage)
  <!--toc:end-->

Eddie uses treesitter to edit html classes in a floating window.

## Usage

Lazy

```lua
local opts = {
  log_level = "warn", -- { "trace", "debug", "info", "warn", "error", "fatal" },
  float = { -- float opts
    height = 20,
    width = 30,
  },
  write_buffer = true, -- write buffer when writing eddie float
  bo = { -- buffer options
    buftype = "acwrite",
    filetype = "eddie",
    swapfile = false,
    buflisted = false,
    bufhidden = "delete",
    modified = false,
  },
  wo = { -- window options
    list = false,
    cursorline = true,
    number = true,
  },
}

return {
  "catgoose/eddie",
  dependencies = "nvim-lua/plenary.nvim",
  opts = opts,
  event = "BufReadPre",
}
```
