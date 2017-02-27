local super = ui.table
ui.filtertable = Object.new(super)

function ui.filtertable:new()
    local self = super.new(self)
    self.searchbar = ui.searchbar:new()
    self.searchbar.m:setFrame{{0,0},{SCREEN.WIDTH,44}}
    self.m:setTableHeaderView(self.searchbar.m)
    function self.searchbar.ontextchange(_, text)
        self:updatefilter(text)
        self:refresh(true)
    end
    return self
end

deblist = Deb.List()
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

function ui.filtertable:updatefilter(text)
    text = text or (self.searchbar and objc.tolua(self.searchbar.m:text()) or '')
    if text == '' then
        filter(nil)
    else
        local t = {}
        local function find(s)
            return s and string.find(string.lower(s), string.lower(text))
        end
        for k,v in pairs(deblist) do
            if find(v.Name) or find(v.Package) then
                t[#t + 1] = v
            end
        end
        filter(t)
    end
end

function ui.filtertable:refresh(skipupdate)
    self.items[1] = list()
    if not skipupdate then
        self:updatefilter()
    end
    super.refresh(self)
end

function ui.filtertable:onscroll()
    super.onscroll(self)
    self.searchbar.m:resignFirstResponder()
end

return ui.filtertable
