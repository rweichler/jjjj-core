local super = Object
local Deb = Object.new(super)

function Deb:new(path, oncomplete)
    local self = super.new(self)

    local control_dir = CACHE_DIR..'/control'

    if path then
        self.path = path
        os.capture('setuid /bin/rm -rf '..control_dir)
        local result = ''
        local result, status = os.capture('setuid /usr/bin/dpkg-deb --control '..path..' '..control_dir)
        if not(status == 0) then
            C.alert_display('Failed getting deb info', result, 'Dismiss', nil, nil)
        else
            local f = io.open(control_dir..'/control', 'r')
            for line in f:lines() do
                local _, _, k, v = string.find(line, '(.*): (.*)')
                if k and v then
                    self[k] = v
                end
            end
            f:close()
        end
    end

    return self
end

function Deb:uninstall(f)
    C.pipeit('setuid /usr/bin/dpkg --remove '..self.Package, f)
end

function Deb:install(f)
    C.pipeit('setuid /usr/bin/dpkg -i '..self.path, f)
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
