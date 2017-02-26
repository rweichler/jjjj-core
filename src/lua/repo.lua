local super = Object
local Repo = Object.new(super)

function Repo:new(url)
    local self = super.new(self)
    self.url = url
    return self
end


local function populate(repolist)
    local t = {}
    for line in (repolist.."\n"):gmatch"(.-)\n" do
        repeat
            local match = string.match(line, '(.*)#.*')
            line = match or line
        until not match

        if not(line == '') then
            local url = string.match(line, 'deb (.*) %.%/')
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
