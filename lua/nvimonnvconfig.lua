local ONNV=require("ONNV");
local Config=require("nvimonnvconfig.config");
local log=require("nvimonnvconfig.log");
local onnvmodules=require("nvimonnvconfig.modules");
local window=require("nvimonnvconfig.window");

local M={}

local initstatuswindow
---@param configuration ONNVConfigure.Config?
function M.setup(configuration)
  log.warn("setup started");
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
  print(vim.fs.root(0,".ONNV.toml"))
  if(vim.fs.root(0,".ONNV.toml"))then
    ONNV.setup({
      path={vim.fs.root(0,".ONNV.toml").."/.ONNV.toml"}
    });
  else
    ONNV.setup({
      path={vim.fn.getcwd().."/.ONNV.toml"}
    });
  end;
  if(not configuration.alwaysInstall)then
    local config=ONNV.getConfig();
    if(config and config.using)then
      M.installModules(config.using);
    end
  end
end


local ModulesInstalled=false;
local modulePostInstallFunctions={};

local function awaitModuleInstallations(functiona)
  if(ModulesInstalled)then
    functiona()
  else
    table.insert(modulePostInstallFunctions,functiona);
  end
end
function M.installModules(modules)
  if(type(modules)=="string")then
    modules={modules};
  end
  initstatuswindow=window.createstatuswindow(modules);
  local installed={};
  for c,modulename in ipairs(modules)do
    local module=onnvmodules.load(modulename);
    if(module)then
      if(module.install)then
        log.warn(string.format("installing module: %s [%d/%d]",modulename,c,#modules));
        installed[modulename]=true;
        module.install(Config,function(statustype,message)
          ---types 0=install finished, 1=message 2=error
          vim.schedule(function()
            initstatuswindow:setmodulestatus(modulename,statustype,message)
          end);
          if(statustype~=0)then
            return
          end
          installed[modulename]=nil;
          if(next(installed)~=nil)then
            return
          end
          ModulesInstalled=true;
          for c,v in ipairs(modulePostInstallFunctions)do
            v();
          end
        end);
      else
        log.warn(string.format("skipping module: %s [%d/%d]",modulename,c,#modules));
      end
    end
  end
end

local function run()
  local config=ONNV.getConfig();
  if(not config)then
    log.warn("could not retrieve config");
    return;
  end
  if(config.type~="oeshennix-onnv")then
    log.warn("config type not valid");
  end
  if(config.version~="0.1.0")then
    log.warn("config version is not set to 0.1.0");
  end

  if(not config.using)then
    return
  end

  if(not config.variables)then
    config.variables={};
  end
  local selfcr;
  --[[
  local continueModules=vim.schedule_wrap(function()
    coroutine.resume(selfcr);
  end)
  ]]
  local function runModules()
    for c,v in ipairs(config.using)do
      local ModuleToLoad=onnvmodules.load(v);
      if(ModuleToLoad)then
        ModuleToLoad.run(config,vim.schedule_wrap(function(statustype,message)
          initstatuswindow:setmodulelog(v,1,".."..message)
          if(statustype==0)then
            coroutine.resume(selfcr);
          end
        end));
        coroutine.yield();
      end
    end
    initstatuswindow:close();
  end
  selfcr=coroutine.create(runModules);
  coroutine.resume(selfcr);
end

function M.run()
  awaitModuleInstallations(run);
end

return M;
