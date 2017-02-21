local super = Object
local Deb = Object.new(super)

function Deb:new(...)
    local self = super.new(self, ...)
    return self
end

function Deb:select(nav)
    nav[#nav + 1] = {
        BACK_BUTTON,
        {
            Name = 'Uninstall',
            select = function(t, nav)
                C.alert_display('Are you sure?', '', 'Cancel', 'Uninstall', function()
                    local cmd = 'dpkg --remove '..self.Package
                    print(cmd)
                    local s, status = os.capture(cmd)
                    print(string.gsub(s, '\n', ' '))
                    nav[#nav] = nil
                    nav[1] = Deb.List()
                    C.alert_display(status == 0 and 'Success' or 'Failed', s, 'Okay', nil, nil)
                    TABLE_VIEW:reloadData()

                end)
            end
        }
    }
    return true
end

function Deb.List()
    local t = {}

    local deb
    local function deblol()
        local ok = 'ok installed'
        if deb and string.sub(deb.Status, #deb.Status - #ok + 1, #deb.Status) == ok then
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
    local lower = string.lower
    table.sort(t, function(a, b)
        if a.Name and b.Name then
            return lower(a.Name) < lower(b.Name)
        elseif not a.Name and not b.Name then
            return lower(a.Package) < lower(b.Package)
        elseif a.Name then
            return true
        else
            return false
        end
    end)
    return t
end

return Deb
