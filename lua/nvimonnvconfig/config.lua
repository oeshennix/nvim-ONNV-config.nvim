local utils=require("nvimonnvconfig.utils");

---@class ONNVConfigure.Config.InstallationType
---@field installation_path string
---@field installation_type "nix-flake"|"nix-traditional"|"build-with-nix"|"build-with-system"
---@field install string[]

---@class ONNVConfigure.Config

local config={}
config.installation_type="nix-flake";
config.install={};
config.alwaysInstall=false;

local M=utils.newconfig(config) --[[@as ONNVConfigure.Config.InstallationType]]
return M;
