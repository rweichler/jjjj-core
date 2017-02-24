local super = Object
ui.cell = Object.new(super)

function ui.cell:new()
    local self = super.new(self)
    return self
end

function ui.cell:getheight(section, row)
    return 44
end

function ui.cell:onselect(section, row)
end
function ui.cell:onshow(m, section, row)
end
function ui.cell:mnew()
    error('not implemented')
end

ui.cell.class = objc.GenerateClass('UITableViewCell')
local class = ui.cell.class

return ui.cell
