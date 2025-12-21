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
      installation_path=require('pckr.config').pack_dir.."/pack/pckr/opt/nvim-ONNV-config.nvim"
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
      installation_path=require('pckr.config').pack_dir.."/pack/pckr/opt/nvim-ONNV-config.nvim"
  end
}
```
or
```lua
{'oeshennix/nvim-ONNV-config.nvim',
  dependencies={
    'oeshennix/ONNV',
  },
  opt={installation_path=YOURLAZYROOT.."/nvim-ONNV-config.nvim"}
  --if you know where your lazy root installation is
}
```

---
## Creating your own config
A basic nvim-ONNV-config uses .ONNV.toml to retrieve configurations for its project.
and should be put to the root of a project.
it should include
`type:type of nvim-ONNV-config`
`using:modules to use.  are called from left to right`
modules are added from addons of nvim-ONNV-config

here is an example from [oeshennix-ONNV-config](https://github.com/oeshennix/oeshennix-ONNV-config.nvim)
```toml
type="oeshennix-ONNV-config"
using=["env","nix","LSP"]
[env]
"ONNVenv"="this string will be put in the environment variable ONNVenv"

[nix]
executables=["nixpkgs#llvmPackages_20.clang-tools"]

[LSP]
clients=["clangd"]
[LSP.clangd]
cmd=["clangd"]
```

nvim-ONNV-config was created to be a base so other people configuration can be built on top of it.

an example of how to do so would be [my own nvim-ONNV-config](https://github.com/oeshennix/oeshennix-ONNV-config.nvim)
