local log=require("nvimonnvconfig.log");
local window = require("nvimonnvconfig.window");
local Config=require("nvimonnvconfig.config");
local M={}
function M.load(module)
  return require("nvimonnvconfig.modules."..module);
end
local ModuleInstallHandler={};
ModuleInstallHandler.__index=ModuleInstallHandler;

function ModuleInstallHandler:log(status_type,message)
  local modulename = rawget(self,"modulename");
  local onlog = rawget(self,"onlog");
  local initstatuswindow = rawget(self,"initstatuswindow");
  log.warn("adsfasdfasdf"..message);
  if(self.initstatuswindow)then
    initstatuswindow:setmodulelog(modulename,status_type,message);
  end
end
function ModuleInstallHandler:onInstall(func)
  local installed = rawget(self,"installed");
  if(not installed)then
    local onInstallFunctions = rawget(self,"onInstallFunctions");
    if(not onInstallFunctions)then
      onInstallFunctions = {};
      self.onInstallFunctions = onInstallFunctions;
    end
    table.insert(onInstallFunctions,func);
    return
  end
  func(0);
end

function ModuleInstallHandler.new(modulename,module,initstatuswindow)
  local info={};
  info.modulename=modulename;
  info.initstatuswindow=initstatuswindow;
  info.installed = false;
  if(not module.install)then
    info.status = "noInstall";
    initstatuswindow:setmodulestatus(modulename,"noInstall");
    return info;
  end
  info.status = "installing";
  setmetatable(info,ModuleInstallHandler);
  local function log_module(status_type,message)
    ---types 0=install finished, 1=message 2=error
    if(status_type~=0)then
      vim.schedule(function()
        info:log(status_type,message)
      end);
      return
    end
    vim.schedule(function()
      initstatuswindow:setmodulestatus(modulename,"installed");
      info:log(status_type,"installed");
    end);
    info.status="installed";
    info.installed=true;
    if(not info.onInstallFunctions)then
      return;
    end
    for _,postinstallfunc in ipairs(info.onInstallFunctions)do
      postinstallfunc(0);
    end
  end
  local function callback_wrapper(user_callback,cleanup)
    local function safe_callback(...)
      local args = {...};
      local success,message = xpcall(
        function()
          return user_callback(unpack(args));
        end,
        debug.traceback
      )
      vim.print(message);
      if(not success)then
        cleanup();
      end
    end
    return safe_callback;
  end
  local success, message = pcall(module.install,Config,callback_wrapper,log_module);
  if(not success)then
    info:log(2,message);
  end
  return info;
end

function M.install(modulename,module,initstatuswindow)
  return ModuleInstallHandler.new(modulename,module,initstatuswindow);
end

local ModulePack={}
ModulePack.__index=ModulePack;
function ModulePack:install()
end
function ModulePack:window()
end

function M.createModulePack(modules)
  local pack = {};
  
  return setmetatable(pack,ModulePack);
end

function M.createmodulewindow(modules)

end
return M;
