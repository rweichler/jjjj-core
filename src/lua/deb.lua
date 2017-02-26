local super = Object
local Deb = Object.new(super)

function Deb:newfromurl(url, oncomplete, onprogress)
    local self = self:new()
    local dl = ns.http:new()
    dl.download = true
    dl.url = url
    function dl.handler(dl, path, percent, errcode)
        if errcode then
            oncomplete(errcode)
        elseif path then
            self:init(path)
            oncomplete()
        elseif percent then
            if onprogress then
                onprogress(percent)
            end
        end
    end
    dl:start()
    return self
end

function Deb:new(path)
    local self = super.new(self)

    if path and not self:init(path) then
        return nil
    end

    return self
end

local control_dir = '/var/tmp/dpkgappcontrol'
function Deb:init(path)
    local function cleanup()
        os.capture('setuid /bin/rm -rf '..control_dir)
    end
    local function die(reason)
        C.alert_display('Failed getting deb info', reason, 'Dismiss', nil, nil)
        cleanup()
    end

    cleanup()
    local result = ''
    local result, status = os.capture('setuid /usr/bin/dpkg-deb --control '..path..' '..control_dir)
    if not(status == 0) then
        die(result)
        return false
    end
    local f = io.open(control_dir..'/control', 'r')
    if not f then
        die('No control file')
        return false
    end
    for line in f:lines() do
        local _, _, k, v = string.find(line, '(.*): (.*)')
        if k and v then
            self[k] = v
        end
    end
    f:close()

    if not self.Package then
        die('Malformed control file')
        return false
    end

    local newpath = CACHE_DIR..'/'..self.Package..'.deb'
    os.capture('setuid /bin/mkdir -p '..CACHE_DIR)
    os.capture('setuid /bin/mv '..path..' '..newpath)

    self.path = newpath
    cleanup()
    return true
end

function Deb:uninstall(f)
    C.pipeit('setuid /usr/bin/dpkg --remove '..self.Package, function(str, status)
        if str == ffi.NULL and status == 0 then
            self.installed = false
        end
        f(str, status)
    end)
end

function Deb:install(f)
    C.pipeit('setuid /usr/bin/dpkg -i '..self.path, function(str, status)
        if str == ffi.NULL and status == 0 then
            self.installed = true
        end
        f(str, status)
    end)
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
                deb.installed = true
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

function Deb.UpdateList()
end

return Deb
