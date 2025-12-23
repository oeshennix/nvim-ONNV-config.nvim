local ONNV=require("ONNV");
local Config=require("nvimonnvconfig.config");
local log=require("nvimonnvconfig.log");
local onnvmodules=require("nvimonnvconfig.modules");

local M={}

---@param configuration ONNVConfigure.Config?
function M.setup(configuration)
  if(configuration)then
    Config(configuration);
  end
  local installation_path=Config.installation_path;
  assert(installation_path,"installation_path is needed to install binarys for nvim-ONNV-config");
  local uv=(vim.uv or vim.loop);
  local installation_path_stat=uv.fs_stat(installation_path);
  if(not installation_path_stat or not installation_path_stat.type=="directory")then
    log.warn(string.format("installation_path \"%s\" is not a valid path",installation_path));
  end
  assert(installation_path_stat and installation_path_stat.type=="directory",string.format("installation_path \"%s\" is not a valid path",installation_path));
  --create bin if it doesnt exist
  local bin_stat=uv.fs_stat(installation_path.."/bin");
  if(bin_stat)then
    assert(bin_stat.type=="directory",string.format("\"%s/bin\" is not a directory move or delete \"%s/bin\"" or not bin_stat,installation_path,installation_path))
  end
  if(not bin_stat)then
    uv.fs_mkdir(installation_path.."/bin",tonumber("770",8));
  end
  ONNV.setup({
    path={vim.fn.getcwd().."/.ONNV.toml"}
  });
end

function M.installModules(modules)
  if(type(modules)=="string")then
    local modulename=modules;
    local module=onnvmodules.load(modulename);
    if(module)then
      if(module.install)then
        module.install(Config);
      end
    end
    return
  end
  for c,modulename in ipairs(modules)do
    local module=onnvmodules.load(modulename);
    if(module)then
      if(module.install)then
        module.install(Config);
      end
    end
  end
end


local validaters={}
function M.addvalidater(func)
  table.insert(validaters,func)
end

function M.run()
  local config=ONNV.getConfig();
  if(not config)then
    log.warn("could not retrieve config");
    return;
  end
  local isvalid=false;
  for c,v in pairs(validaters)do
    if(v(config))then
      isvalid=true;
      break
    end
  end
  if(not isvalid)then
    return
  end

  if(not config.using)then
    return
  end

  if(not config.variables)then
    config.variables={};
  end
  for c,v in ipairs(config.using)do
    local ModuleToLoad=onnvmodules.load(v);
    if(ModuleToLoad)then
      print("hi");
      ModuleToLoad.run(config);
    end
  end
end

return M;
