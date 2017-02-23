local super = Object
local Depiction = Object.new(super)

function Depiction:new()
    local self = super.new(self)
    return self
end

function Depiction:gettitle()
    return self.deb.Name or self.deb.Package
end

function Depiction:getauthor()
    local author = self.deb.Author
    if not author then return end

    local firstcarrot = string.find(author, '%<')
    if firstcarrot then
        return string.sub(author, 1, firstcarrot - 1)
    else
        return author
    end
end

function Depiction:load(m)
    m.view:setBackgroundColor(objc.UIColor:whiteColor())

    local author = self:getauthor()
    if author then
        local label = objc.UILabel:alloc():init()
        label:setFrame{{20, 80},{60,44}}
        label:setText('by '..self:getauthor())
        label:sizeToFit()
        m.view:addSubview(label)
    end

    local button = ui.button:new()
    button.m:setFrame{{20,120},{70, 44}}
    button:setTitle('Uninstall')
    m.view:addSubview(button.m)
    function button.ontoggle()
        C.alert_display('Uninstall', 'Do you really want to uninstall '..self.deb.Package..'?', 'Cancel', 'Uninstall', function()
            local old = button.ontoggle
            button.ontoggle = function() end
            button:setTitle('Uninstalling...')
            local result = ''
            self.deb:uninstall(function(line, status)
                if line == ffi.NULL then
                    if status == 0 then
                        POPCONTROLLER()
                        NAV[1] = Deb.List()
                        THE_TABLE:updatefilter()
                        THE_TABLE:refresh()
                        C.alert_display('Uninstalled '..self.deb.Package, 'Woooooo!', 'Dismiss', nil, nil)
                    else
                        C.alert_display('Failed to uninstall '..self.deb.Package, result, 'Dismiss', nil, nil)
                        button.ontoggle = old
                        button:setTitle('Uninstall')
                    end
                else
                    result = result..ffi.string(line)
                end
            end)
        end)
    end
end

return Depiction
