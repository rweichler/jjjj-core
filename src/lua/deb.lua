local super = Object
local Deb = Object.new(super)

function Deb:new(...)
    local self = super.new(self, ...)
    return self
end

function Deb.List()
    local t = {}

    local deb
    local function deblol()
        if deb and deb.Status == 'install ok installed' then
            t[#t + 1] = deb
        end
    end

    local f = io.open('/var/lib/dpkg/status', 'r')
    for line in f:lines() do
        local _, _, k, v = string.find(line, '(.*): (.*)')
        if k and v then
            if k == 'Package' then
                deblol()
                deb = Deb:new()
            end
            deb[k] = v
        end
    end
    f:close()
    deblol()
    table.sort(t, function(a, b)
        return a.Package < b.Package
    end)
    return t
end

return Deb
