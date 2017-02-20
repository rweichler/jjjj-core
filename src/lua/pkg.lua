local Object = require 'object'

local super = Object
local Pkg = Object.new(super)

function Pkg:new(...)
    local self = super.new(self, ...)
    return self
end

function Pkg.List()
    local t = {}

    local pkg
    local function addpkg()
        if pkg and pkg.Status == 'install ok installed' then
            t[#t + 1] = pkg
        end
    end

    local f = io.open('/var/lib/dpkg/status', 'r')
    for line in f:lines() do
        local _, _, k, v = string.find(line, '(.*): (.*)')
        if k and v then
            if k == 'Package' then
                addpkg()
                pkg = Pkg:new()
            end
            pkg[k] = v
        end
    end
    f:close()
    addpkg()
    return t
end

return Pkg
