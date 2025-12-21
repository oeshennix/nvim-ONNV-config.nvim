# nvim-ONNV-config
a simple neovim project config retriever using ONNV

---
## setup

### [pckr.nvim](https://github.com/lewis6991/pckr.nvim)
```lua
{'oeshennix/nvim-ONNV-config.nvim',
  requires={
    'oeshennix/ONNV',
  },
  config=function()
    require('nvimonnvconfig').setup({
      installation_path=require('pckr.config').pack_dir.."/pack/pckr/opt/oeshennix-ONNV-configure.nvim"
    });
  end
}
```
### [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{'oeshennix/nvim-ONNV-config.nvim',
  dependencies={
    'oeshennix/ONNV',
  },
  config=function()
    require("nvimonnvconfig").setup{installation_path=require('lazy.core.config').options.root.."/oeshennix-ONNV-configure.nvim"}
  end
}
```
or
```lua
{'oeshennix/nvim-ONNV-config.nvim',
  dependencies={
    'oeshennix/ONNV',
  },
  opt={installation_path=YOURLAZYROOT.."/oeshennix-ONNV-configure.nvim"}
  --if you know where your lazy root installation is
}
```

---
## Creating your own config
nvim-ONNV-config was created to be a base so other people configuration can be built on top of it.

an example of how to do so would be [my own nvim-ONNV-config](https://github.com/oeshennix/oeshennix-ONNV-config.nvim)
