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

ui.cell.mname = 'UITableViewCell'
ui.cell.class = objc.Class(ui.cell.mname)
local class = ui.cell.class

return ui.cell
