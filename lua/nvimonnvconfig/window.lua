local M={};

---@class statuswindow
---@field buf number
---@field win number

local statuswindow={}
statuswindow.__index=statuswindow;

---@param statustype number
---@param message string
function statuswindow:setmodulestatus(module,statustype,message)
  local buf=rawget(self,"buf");
  local position=rawget(self,"modulepositions")[module];
  vim.api.nvim_buf_set_lines(buf,position+1,position+2,true,{"  "..message});
end
function statuswindow:setmodulelog(module,statustype,message)
  local buf=rawget(self,"buf");
  local position=rawget(self,"modulepositions")[module];
  vim.api.nvim_buf_set_lines(buf,position+2,position+3,true,{"  "..message});
end
function statuswindow:registermoduleposititioninwindow()
  local buf=rawget(self,"buf");
  local modules=rawget(self,"modules");
  local modulepositions={}
  local replace={};
  for c,v in ipairs(modules)do
    local position=(c-1)*3;
    modulepositions[v]=position
    table.insert(replace,v);
    table.insert(replace,"");
    table.insert(replace,"");
  end
  vim.api.nvim_buf_set_lines(buf,0,0,true,replace);
  rawset(self,"modulepositions",modulepositions);
end

function M.createinitwindow()
  local buf=vim.api.nvim_create_buf(false,true);
  local width=vim.o.columns
  local height=vim.o.lines
  ---@type vim.api.keyset.win_config
  local winconfig = {
    relative="editor",
    width=60,
    height=20,
    anchor="SW",
    row=0,
    col=width,
    border={"/","-","\\","|","/","-","\\","|"},
    title="Building Nix",
    title_pos='center',
  }
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

function M.createstatuswindow(modules)
  local buf,win=M.createinitwindow();
  local newstatuswindow={};
  newstatuswindow.buf=buf;
  newstatuswindow.win=win;
  newstatuswindow.modules=modules;
  setmetatable(newstatuswindow,statuswindow);
  newstatuswindow:registermoduleposititioninwindow();
  return newstatuswindow;
end
return M;
