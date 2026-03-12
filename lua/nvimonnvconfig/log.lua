local M={}

local messages={};
function M.warn(message)
  table.insert(messages,string.format("[nvim-ONNV-config.log]:%s",message));
  vim.g.oONNVlog=messages;
end
vim.g.oONNVlog=messages;
return M;
