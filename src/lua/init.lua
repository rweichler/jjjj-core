jit.off()
local argc, argv = ...
package.path = PATH..'/?.lua;'..
               PATH..'/?/init.lua;'..
               package.path

config = require 'config'
objc = require 'objc'
local count = 0
function objc.Class(super, ...)
    super = super or 'NSObject'
    count = count + 1
    local name = 'DPKGAPP_'..count..super

    if ... then
        objc.class(name, super..'<'..table.concat({...}, ',')..'>')
    else
         objc.class(name, super)
    end

    return objc[name]
end
local objc_objz = {}
function objc.Lua(obj, set)
    local hash = tonumber(ffi.cast('uintptr_t',obj))
    local result = objc_objz[hash]
    if set then
        if result then error('wtf???') end
        objc_objz[hash] = set
        result = set
    end
    return result
end
ffi = require 'ffi'
C = ffi.C
bit = require 'bit'
require 'cdef'
require 'util'

OLD_UID = C.getuid()
OLD_GID = C.getgid()

C.setuid(0)
C.setgid(0)

Object = require 'object'
Deb = require 'deb'
Downloader = require 'downloader'

ui = {}
require 'ui.table'
require 'ui.cell'
require 'ui.searchbar'

for _,fname in ipairs(ls(PATH..'/class')) do
    if string.sub(fname, #fname - 3, #fname) == '.lua' then
        require('class.'..string.sub(fname, 1, #fname - 4))
    elseif isdir(PATH..'/'..fname) then
        require('class.'..fname)
    end
end

return C.UIApplicationMain(argc, argv, nil, objc.toobj('AppDelegate'))
