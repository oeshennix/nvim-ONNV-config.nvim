# Migrating
There are some incompatibility with the previous version 0.0.1.
Onnvmodules now needs their 2nd parameter to be a callback that may be
called with the parameters (status:number,message:string).  And has to
be called with status as 0 to signal that the module is done installing.

# Incompatibility
## Incompatibility from version vim 0.0.1
As of version 0.1.0 nvim-ONNV.
* The configuration file now needs version to be set to version "0.1.0".  
* nvimonnvconfig.installModules() now passed a callback function to the
requesting modules.  nvimonnvconfig.run() will wait for each modules to
be installed in order to continue.
