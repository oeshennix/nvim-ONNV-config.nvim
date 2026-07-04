local log=require("nvimonnvconfig.log");
local M={};

---@alias modulename string name of module

---@alias modulestatus "installing" | "installed" | "noInstall" 

---@class statuswindow
---@field buf number
---@field win number
---@field modules string[]
---@field modulestatuses {string:modulestatus}
local statuswindow={}
statuswindow.__index=statuswindow;

---@param module modulename
---@param marker string
function statuswindow:setmodulemark(module,marker)
  local buf=rawget(self,"buf");
  local position=rawget(self,"modulepositions")[module];
  local modulemarkers= rawget(self,"markers");
  local modulemarker = modulemarkers[module];
  local onnv_nix=vim.api.nvim_create_namespace("onnv_nix");
  modulemarker.virt_text[1][1]=marker;
  vim.api.nvim_buf_set_extmark(buf,onnv_nix,position,0,modulemarker);
end

---@param module modulename
---@param status modulestatus
function statuswindow:setmodulestatus(module,status)
  local modulestatuses = rawget(self,"modulestatuses") --[[@as modulestatus]];
  modulestatuses[module]=status;
  if(status == "installed")then
    self:setmodulemark(module,"I");
  else if(status == "noInstall")then
    self:setmodulemark(module,"#");
  end
  end
end
---@param module modulename
---@param message string
function statuswindow:setmodulelog(module,message)
  local buf=rawget(self,"buf");
  local position=rawget(self,"modulepositions")[module];
  if(not position)then
    log.warn("status window not created");
    log.warn("format thing "..vim.inspect(module)..vim.inspect(rawget(self,"modulepositions")));
  else
    message=string.gsub(message,"\n","[NEWLINE]");
    vim.api.nvim_buf_set_lines(buf,position+2,position+3,true,{"  "..message});
  end
end
function statuswindow:registermoduleposititioninwindow()
  local buf=rawget(self,"buf");
  local modules=rawget(self,"modules");
  local modulepositions={}
  local modulevirttext={};
  local replace={};
  for c,v in ipairs(modules)do
    local position=(c-1)*3;
    modulepositions[v]=position
    table.insert(replace,v);
    table.insert(replace,"");
    table.insert(replace,"");
  end

  vim.api.nvim_buf_set_lines(buf,0,0,true,replace);

  local onnv_nix=vim.api.nvim_create_namespace("onnv_nix");
  for _,v in ipairs(modules)do
    local position = modulepositions[v]
    local mark = {
      virt_text_pos = "overlay",
      virt_text = {
        {v,"magenta"}
      },
      priority = 5000
    }
    vim.api.nvim_buf_set_extmark(buf,onnv_nix,position,0,mark);
  end
  rawset(self,"modulevirttext",modulevirttext);
  rawset(self,"modulepositions",modulepositions);
end
function statuswindow:registermarkers()
  local buf=rawget(self,"buf");
  local modules = rawget(self,"modules");

  local modulepositions = rawget(self,"modulepositions");
  local onnv_nix=vim.api.nvim_create_namespace("onnv_nix");
  local markers = {};
  for _,module in ipairs(modules)do
    local extmark={
      virt_text={{"hi","magenta"},{" ","none"}},
      virt_text_pos="inline"
    }
    local position = modulepositions[module];
    local markerid=vim.api.nvim_buf_set_extmark(buf,onnv_nix,position,0,extmark);
    extmark.id=markerid;
    markers[module] = extmark;
  end
  self.markers = markers;
end
function statuswindow:close()
  local buf=rawget(self,"buf");
  local win=rawget(self,"win");
  vim.api.nvim_win_close(win,true);
  vim.api.nvim_buf_delete(buf,{force=true});
  local spinnertimer=self.spinnertimer;
  vim.uv.timer_stop(spinnertimer);
  vim.uv.close(spinnertimer);
end
local braile_spinner={"⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧"};
function statuswindow:newspinner()
  local buf=rawget(self,"buf");

  local modules = rawget(self,"modules");
  local modulepositions = rawget(self,"modulepositions");
  assert(modulepositions,"modulepositions does not exist");
  local spinnerpt=1;

  for _,module in ipairs(modules)do
    if(self.modulestatuses[module]=="installing")then
      self:setmodulemark(module,braile_spinner[spinnerpt]);
    end
  end


  local spinnertimer=vim.uv.new_timer();
  assert(spinnertimer,"could not create timer for spinner");
  spinnertimer:start(0,100,function()
    vim.schedule(function()
      if(not vim.api.nvim_buf_is_valid(buf))then return end
      spinnerpt=(spinnerpt)%8+1;
      for _,module in ipairs(self.modules) do
        local status = self.modulestatuses[module];
        if(status=="installing")then
          self:setmodulemark(module,braile_spinner[spinnerpt]);
        end
      end
    end);
  end);
  self.spinnermarks = {};
  self.spinnertimer=spinnertimer;
end

function M.createinitwindow(windowconfig)
  local buf=vim.api.nvim_create_buf(false,true);
  local width=vim.o.columns
  --local height=vim.o.lines
  ---@type vim.api.keyset.win_config
  local winconfig = vim.tbl_extend("keep",windowconfig,
    {
      relative="editor",
      width=60,
      height=20,
      anchor="SW",
      row=0,
      col=width,
      border="rounded",
      title="Building Modules",
      title_pos='center',
    }
  )
  local onnv_nix=vim.api.nvim_create_namespace("onnv_nix");
  local win=vim.api.nvim_open_win(buf,false,winconfig);
  vim.api.nvim_buf_set_lines(buf,0,1,true,{"hello"});
  vim.api.nvim_set_hl(onnv_nix,"magenta",{fg="#FF00FF"});
  vim.api.nvim_win_set_hl_ns(win,onnv_nix);
  ---@type vim.api.keyset.set_extmark
  local extmark={
    virt_text={{":)","magenta"}};
    virt_text_pos="inline",
  };
  vim.api.nvim_buf_set_extmark(buf,onnv_nix,0,0,extmark);
  return buf,win
end

---@param modules modulename[]
function M.createstatuswindow(modules)
  local buf,win=M.createinitwindow({});
  local newstatuswindow={};
  newstatuswindow.buf=buf;
  newstatuswindow.win=win;
  newstatuswindow.modules=modules;
  newstatuswindow.modulestatuses={};
  newstatuswindow.statusmarks={};
  setmetatable(newstatuswindow,statuswindow);
  newstatuswindow:registermoduleposititioninwindow();
  newstatuswindow:registermarkers();
  newstatuswindow:newspinner();
  for _,module in ipairs(modules) do
    newstatuswindow:setmodulestatus(module,"installing");
  end
  return newstatuswindow;
end
return M;
