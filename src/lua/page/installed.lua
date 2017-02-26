local deblist = Deb.List()
local lastfiltered, filtered
local function list()
    if filtered then
        if lastfiltered == deblist then
            return filtered
        else
            filtered = nil
        end
    end
    lastfiltered = nil
    return deblist
end

local function filter(t)
    filtered = t
    if filtered then
        lastfiltered = deblist
    else
        lastfiltered = nil
    end
end

local function strfind(s, text)
    if not s or not text then return end
    return string.find(string.lower(s), string.lower(text))
end

local tbl = ui.table:new()
tbl.items = {}
function tbl:onscroll(x, y)
    if self.searchbar then
        self.searchbar.m:resignFirstResponder()
    end
end

tbl.cell = ui.cell:new()
tbl.cell.identifier = objc.toobj('lolwatttt')

function tbl:updatefilter(text)
    text = text or (self.searchbar and objc.tolua(self.searchbar.m:text()) or '')
    if text == '' then
        filter(nil)
    else
        local t = {}
        for k,v in pairs(deblist) do
            if strfind(v.Name, text) or strfind(v.Package, text) then
                t[#t + 1] = v
            end
        end
        filter(t)
    end
end

function tbl:refresh(...)
    self.items[1] = list()
    ui.table.refresh(self, ...)
end
function tbl.cell:onselect(section, row)
    if self.searchbar then
        tbl.searchbar.m:resignFirstResponder()
    end
    local depiction = Depiction:new()
    depiction.deb = tbl.items[section][row]
    PUSHCONTROLLER(function(m)
        depiction:view(m)
    end, depiction:gettitle())
end

function tbl.cell:onshow(m, section, row)
    local deb = tbl.items[section][row]
    if not deb then return end

    local img = nil
    if deb.Section then
        local path = '/Applications/Cydia.app/Sections/'..string.gsub(deb.Section, ' ', '_')..'.png'
        local f = io.open(path, 'r')
        if f then
            f:close()
        else
            path = '/Applications/Cydia.app/unknown.png'
        end
        img = objc.UIImage:imageWithContentsOfFile(path)
    end

    m:imageView():setImage(img)
    m:textLabel():setText(deb.Name or deb.Package)
    m:detailTextLabel():setText(deb.Description or '')
end
tbl:refresh()

tbl.searchbar = ui.searchbar:new()
tbl.searchbar.m:setFrame{{0, 0}, {SCREEN.WIDTH, 44}}
tbl.m:setTableHeaderView(tbl.searchbar.m)

function tbl.searchbar:ontextchange(text)
    tbl:updatefilter(text)
    tbl:refresh()
end

HOOK(Deb, 'UpdateList', function(orig, ...)
    deblist = Deb.List()
    tbl:updatefilter()
    tbl:refresh()
    return orig(...)
end)


_G.NAVCONTROLLER = objc.UINavigationController:alloc():initWithRootViewController(VIEWCONTROLLER(function(m)
    tbl.m:setFrame(m:view():bounds())
    m:view():addSubview(tbl.m)
end, 'Installed'))

_G.NAVHEIGHT = function()
    return 64
end

_G.BARHEIGHT = function()
    -- TODO return 56 on iOS 7
    return 49
end


local path = '/Applications/Cydia.app/manage7@2x.png'
NAVCONTROLLER:tabBarItem():setImage(objc.UIImage:imageWithContentsOfFile(path))

table.insert(TABCONTROLLERS, NAVCONTROLLER)
