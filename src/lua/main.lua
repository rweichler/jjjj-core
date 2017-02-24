_G.BACK_BUTTON = {
    Name = '<-- back',
    select = function(self, nav)
        nav[#nav] = nil
        nav[1] = Deb.List()
        return true
    end,
}

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

local table = ui.table:new()
table.items = {}
function table:onscroll(x, y)
    if self.searchbar then
        self.searchbar.m:resignFirstResponder()
    end
end

table.cell = ui.cell:new()
table.cell.identifier = objc.toobj('lolwatttt')

function table:updatefilter(text)
    text = text or (self.searchbar and objc.tolua(self.searchbar.m.text) or '')
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

function table:refresh(...)
    self.items[1] = list()
    ui.table.refresh(self, ...)
end
function table.cell:onselect(section, row)
    if self.searchbar then
        table.searchbar.m:resignFirstResponder()
    end
    local item = table.items[section][row]
    if item and item.select then
        if item:select(nav) then
            table:updatefilter()
            table:refresh()
        end
    else
        local depiction = Depiction:new()
        depiction.deb = item
        PUSHCONTROLLER(function(m)
            depiction:load(m)
        end, depiction:gettitle())
    end
end
function table.cell:mnew()
    return objc.UITableViewCell:alloc():initWithStyle_reuseIdentifier(3, self.identifier)
end
function table.cell:onshow(m, section, row)
    local deb = table.items[section][row]
    if not deb then return end

    local img = nil
    if deb.Section then
        local path = '/Applications/Cydia.app/Sections/'..string.gsub(deb.Section, ' ', '_')..'.png'
        local f = io.open(path, 'r')
        if f then
            f:close()
            img = objc.UIImage:imageWithContentsOfFile(path)
        end
    end

    m.imageView:setImage(img)
    m.textLabel:setText(deb.Name or deb.Package)
    m.detailTextLabel:setText(deb.Description or '')
end
table:refresh()

table.searchbar = ui.searchbar:new()
table.searchbar.m:setFrame{{0, 0}, {SCREEN.WIDTH, 44}}
table.m.tableHeaderView = table.searchbar.m

function table.searchbar:ontextchange(text)
    table:updatefilter(text)
    table:refresh()
end

_G.THE_TABLE = table

local window = objc.UIWindow:alloc():init():retain()

local vc = VIEWCONTROLLER(function(m)
    local size = m.view:frame().size
    table.m:setFrame{{0, 0}, {size.width, size.height}}
    m.view:addSubview(table.m)
end, 'Your tweaks')

_G.NAVCONTROLLER = objc.UINavigationController:alloc():initWithRootViewController(vc)
window:setRootViewController(NAVCONTROLLER:retain())
window:makeKeyAndVisible()


_G.PUSHCONTROLLER = function(f, title)
    NAVCONTROLLER:pushViewController_animated(VIEWCONTROLLER(f, title), true)
end

_G.POPCONTROLLER = function()
    NAVCONTROLLER:popViewControllerAnimated(true)
end

require 'openurl'
