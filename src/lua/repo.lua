local super = Object
local Repo = Object.new(super)

function Repo:new(url)
    local self = super.new(self)
    self.url = url
    self.prettyurl = string.gsub(string.gsub(self.url, 'http://', ''), 'https://', '')
    self.prettyurl = string.sub(self.prettyurl, 1, #self.prettyurl - 1)
    return self
end

function Repo:getrelease(callback)
    local dl = ns.http:new()
    dl.url = self.url..'Release'
    function dl.handler(dl, data, percent, errcode)
        if errcode then
        elseif data then
            local str = objc.tolua(objc.NSString:alloc():initWithData_encoding(data, NSUTF8StringEncoding))
            for line in (str.."\n"):gmatch"(.-)\n" do
                local k,v = Deb.ParseLine(line)
                if k and v then
                    self[k] = v
                end
            end
            callback()
        end
    end
    dl:start()
end

function Repo:getpackages(callback)
    local dl = ns.http:new()
    dl.url = self.url..'Packages.bz2'
    dl.download = true
    function dl.handler(dl, path, percent, errcode)
        if errcode then
        elseif path then
            local home = CACHE_DIR..'/repos'
            os.capture('setuid /bin/mkdir -p '..home)
            self.path = home..'/'..self.prettyurl
            os.capture('setuid /bin/mv '..path..' '..self.path..'.bz2')
            os.capture('setuid /bin/bunzip2 '..self.path..'.bz2')
            self.debs = Deb.List(self.path)
            callback()
        end
    end
    dl:start()
end

function Repo:geticon(callback)
    local dl = ns.http:new()
    dl.url = self.url..'CydiaIcon.png'
    function dl.handler(dl, data, percent, errcode)
        if data then
            self.icon = objc.UIImage:alloc():initWithData(data)
            callback()
        end
    end
    dl:start()
end


local function populate(repolist)
    local t = {}
    for line in (repolist.."\n"):gmatch"(.-)\n" do
        repeat
            local match = string.match(line, '(.*)#.*')
            line = match or line
        until not match

        if not(line == '') then
            local url = string.match(line, 'deb%s+(.*/)%s+%.%/')
            t[#t + 1] = Repo:new(url)
        end
    end
    return t
end

function Repo.List(url, oncomplete)
    local dl = ns.http:new()
    dl.url = 'https://raw.githubusercontent.com/jonluca/MasterRepo/master/masterrepoeasyinstall/etc/apt/sources.list.d/MasterRepo.list'
    function dl.handler(dl, data, percent, errcode)
        if data then
            local str = objc.NSString:alloc():initWithData_encoding(data, NSUTF8StringEncoding)
            oncomplete(populate(objc.tolua(str)))
        else
            print(data)
            print(percent)
            print(errcode)
        end
    end
    dl:start()

end

return Repo
