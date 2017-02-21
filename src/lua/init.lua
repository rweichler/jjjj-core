jit.off()
local argc, argv = ...
package.path = PATH..'/?.lua;'..
               PATH..'/?/init.lua;'..
               package.path

objc = require 'objc'
ffi = require 'ffi'
C = ffi.C
bit = require 'bit'
require 'cdef'
require 'util'

C.setuid(0)
C.setgid(0)

Object = require 'object'
Deb = require 'deb'

for _,fname in ipairs(ls(PATH..'/class')) do
    if string.sub(fname, #fname - 3, #fname) == '.lua' then
        require('class.'..string.sub(fname, 1, #fname - 4))
    elseif isdir(PATH..'/'..fname) then
        require('class.'..fname)
    end
end

return C.UIApplicationMain(argc, argv, nil, objc.toobj('AppDelegate'))
