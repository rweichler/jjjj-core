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
    m:view():setBackgroundColor(objc.UIColor:whiteColor())

    local author = self:getauthor()
    if author then
        local label = objc.UILabel:alloc():init()
        label:setFrame{{20, NAVHEIGHT()},{60,44}}
        label:setText('by '..self:getauthor())
        label:sizeToFit()
        m:view():addSubview(label)
    end

    local target = ns.target:new()
    local button = objc.UIBarButtonItem:alloc():initWithTitle_style_target_action('Uninstall', UIBarButtonItemStylePlain, target.m, target.sel)
    m:navigationItem():setRightBarButtonItem(button)

    function target.onaction()
        C.alert_display('Uninstall', 'Do you really want to uninstall '..self.deb.Package..'?', 'Cancel', 'Uninstall', function()
            local old = target.onaction
            target.onaction = function() end
            button:setTitle('Uninstalling...')
            local result = ''

            local label = objc.UILabel:alloc():init()
            label:setFont(objc.UIFont:fontWithName_size('Courier', 12))
            label:setBackgroundColor(objc.UIColor:blackColor())
            label:setTextColor(objc.UIColor:whiteColor())
            label:setNumberOfLines(0)
            label:setText('')
            local function appendtext(s)
                label:setText(objc.tolua(label:text())..s)
                label:sizeToFit()
                label:setFrame{{0, NAVHEIGHT()}, {m:view():frame().size.width, label:frame().size.height}}
            end
            appendtext('$ dpkg --remove '..self.deb.Package..'\n')
            m:view():addSubview(label)


            self.deb:uninstall(function(line, status)
                if line == ffi.NULL then
                    if status == 0 then
                        m:navigationItem():setRightBarButtonItem(nil)
                        --POPCONTROLLER()
                        appendtext('Success! :D')
                        NAV[1] = Deb.List()
                        THE_TABLE:updatefilter()
                        THE_TABLE:refresh()
                        C.alert_display('Uninstalled '..self.deb.Package, 'Woooooo!', 'Dismiss', nil, nil)
                    else
                        C.alert_display('Failed to uninstall '..self.deb.Package, result, 'Dismiss', nil, nil)
                        button.onaction = old
                        button:setTitle('Uninstall')
                    end
                else
                    local s = ffi.string(line)
                    appendtext(s)
                    result = result..s
                end
            end)
        end)
    end
end

return Depiction
