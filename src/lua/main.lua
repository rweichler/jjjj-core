local nav = {}
NAV = nav
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

nav[#nav + 1] = Deb.List()





local table = ui.table:new()
table.items = {}
table.m:setFrame{{0, 20}, {SCREEN.WIDTH, SCREEN.HEIGHT-20}}
function table:onscroll(x, y)
    self.searchbar.m:resignFirstResponder()
end

table.cell = ui.cell:new()
table.cell.identifier = objc.toobj('lolwatttt')


function table:refresh(...)
    self.items[1] = list()
    ui.table.refresh(self, ...)
end
function table.cell:onselect(section, row)
    local deb = table.items[section][row]
    if deb and deb.select then
        if deb:select(nav) then
            table:refresh()
        end
    end
end
function table.cell:mnew()
    return objc.UITableViewCell:alloc():initWithStyle_reuseIdentifier(3, self.identifier)
end
function table.cell:onshow(m, section, row)
    local deb = table.items[section][row]

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

local function strfind(s, text)
    if not s or not text then return end
    return string.find(string.lower(s), string.lower(text))
end
function table.searchbar:ontextchange(text)
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
    table:refresh()
end

THE_TABLE = table
return table.m
