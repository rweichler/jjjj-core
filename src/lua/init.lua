jit.off()
local argc, argv = ...
package.path = PATH..'/?.lua;'..
               PATH..'/?/init.lua;'..
               package.path

config = require 'config'
objc = require 'objc'
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

for _,fname in ipairs(ls(PATH..'/class')) do
    if string.sub(fname, #fname - 3, #fname) == '.lua' then
        require('class.'..string.sub(fname, 1, #fname - 4))
    elseif isdir(PATH..'/'..fname) then
        require('class.'..fname)
    end
end

return C.UIApplicationMain(argc, argv, nil, objc.toobj('AppDelegate'))
