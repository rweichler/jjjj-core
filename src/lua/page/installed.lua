local nav = {}
_G.NAV = nav
local lastfiltered
local filtered
local function list()
    if filtered then
        if lastfiltered == nav[#nav] then
            return filtered
        else
            filtered = nil
        end
    end
    lastfiltered = nil
    return nav[#nav]
end

local function filter(t)
    filtered = t
    if filtered then
        lastfiltered = nav[#nav]
    else
        lastfiltered = nil
    end
end

local function strfind(s, text)
    if not s or not text then return end
    return string.find(string.lower(s), string.lower(text))
end


nav[#nav + 1] = Deb.List()

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
        for k,v in pairs(nav[#nav]) do
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
    local item = tbl.items[section][row]
    if item and item.select then
        if item:select(nav) then
            tbl:updatefilter()
            tbl:refresh()
        end
    else
        local depiction = Depiction:new()
        depiction.deb = item
        PUSHCONTROLLER(function(m)
            depiction:view(m)
        end, depiction:gettitle())
    end
end
function tbl.cell:mnew()
    return objc.UITableViewCell:alloc():initWithStyle_reuseIdentifier(3, self.identifier)
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

_G.THE_TABLE = tbl


local vc = VIEWCONTROLLER(function(m)
    local size = m:view():frame().size
    tbl.m:setFrame{{0, 0}, {size.width, size.height}}
    m:view():addSubview(tbl.m)
end, 'Installed')

_G.NAVCONTROLLER = objc.UINavigationController:alloc():initWithRootViewController(vc)
_G.NAVHEIGHT = function()
    return 64
end


local path = '/Applications/Cydia.app/manage7@2x.png'
NAVCONTROLLER:tabBarItem():setImage(objc.UIImage:imageWithContentsOfFile(path))

table.insert(TABCONTROLLERS, NAVCONTROLLER)
