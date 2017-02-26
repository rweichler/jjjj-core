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
            depiction:view(m)
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
        else
            path = '/Applications/Cydia.app/unknown.png'
        end
        img = objc.UIImage:imageWithContentsOfFile(path)
    end

    m:imageView():setImage(img)
    m:textLabel():setText(deb.Name or deb.Package)
    m:detailTextLabel():setText(deb.Description or '')
end
table:refresh()

table.searchbar = ui.searchbar:new()
table.searchbar.m:setFrame{{0, 0}, {SCREEN.WIDTH, 44}}
table.m:setTableHeaderView(table.searchbar.m)

function table.searchbar:ontextchange(text)
    table:updatefilter(text)
    table:refresh()
end

_G.THE_TABLE = table

local window = objc.UIWindow:alloc():initWithFrame(objc.UIScreen:mainScreen():bounds()):retain()

local vc = VIEWCONTROLLER(function(m)
    local size = m:view():frame().size
    table.m:setFrame{{0, 0}, {size.width, size.height}}
    m:view():addSubview(table.m)
end, 'Installed')

_G.NAVCONTROLLER = objc.UINavigationController:alloc():initWithRootViewController(vc)
_G.NAVHEIGHT = function()
    return 64
end

_G.REPOCONTROLLER = objc.UINavigationController:alloc():initWithRootViewController(VIEWCONTROLLER(function(m)
end, 'Repos'))
local path = '/Applications/Cydia.app/install7@2x.png'
REPOCONTROLLER:tabBarItem():setImage(objc.UIImage:imageWithContentsOfFile(path))

local path = '/Applications/Cydia.app/manage7@2x.png'
NAVCONTROLLER:tabBarItem():setImage(objc.UIImage:imageWithContentsOfFile(path))

_G.BROWSECONTROLLER = objc.UINavigationController:alloc():initWithRootViewController(VIEWCONTROLLER(function(m)
end, 'Browse'))
local path = RES_PATH..'/globe.png'
BROWSECONTROLLER:tabBarItem():setImage(objc.UIImage:imageWithContentsOfFile(path))

_G.TABBARCONTROLLER = objc.UITabBarController:alloc():init()
TABBARCONTROLLER:setViewControllers{
    REPOCONTROLLER,
    NAVCONTROLLER,
    BROWSECONTROLLER,
}
window:setRootViewController(TABBARCONTROLLER)
window:makeKeyAndVisible()


_G.PUSHCONTROLLER = function(f, title)
    NAVCONTROLLER:pushViewController_animated(VIEWCONTROLLER(f, title), true)
end

_G.POPCONTROLLER = function()
    NAVCONTROLLER:popViewControllerAnimated(true)
end

_G.ANIMATE = function(arg1, arg2, arg3, arg4, arg5)
    local duration = 0.2
    local delay = 0
    local options = UIViewAnimationOptionCurveEaseInOut
    local animations
    local completion = function(finished)
        return animations(finished)
    end
    if type(arg1) == 'table' then
        duration = arg1.duration or duration
        delay = arg1.delay or delay
        options = arg1.options or options
        animations = arg1.animations or animations
    elseif not arg2 and not arg3 then
        animations = arg1
    elseif not arg3 then
        duration = arg1
        animations = arg2
    elseif not arg4 then
        duration = arg1
        delay = arg2
        animations = arg3
    else
        duration, delay, options, animations = arg1, arg2, arg3, arg4
    end
    C.animateit(duration, delay, options, animations, completion)
end
_G.OPENURL = function(url)
    PUSHCONTROLLER(function(m)
        local depiction = Depiction:new(url)
        depiction:viewdownload(m)
    end, 'Install deb')
end
