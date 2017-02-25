local super = Object
local Depiction = Object.new(super)

function Depiction:new(arg1)
    local self = super.new(self)

    if type(arg1) == 'table' then
        self.deb = arg1
    elseif type(arg1) == 'string' then
        local url = arg1
        self.deb = Deb:newfromurl(url, function(err)
            self:ondownloadcomplete()
        end, function(percent)
            local dl = self.downloadbar
            dl.progress:setProgress(percent)
            dl.percent:setText(math.floor(percent*100 + 0.5)..'%')
        end)
    end

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

function Depiction:ondownloadcomplete()
    local m = self.m
    self.m = nil

    self.downloadbar.m:removeFromSuperview()
    self.downloadbar = nil

    local namelabel = objc.UILabel:alloc():init()
    namelabel:setFrame{{0, NAVHEIGHT()},{60,44}}
    namelabel:setText(self.deb.Name or self.deb.Package)
    namelabel:sizeToFit()
    m:view():addSubview(namelabel)

    self:yeahdude(m)
end

function Depiction:viewdownload(m)
    m:view():setBackgroundColor(objc.UIColor:whiteColor())

    self.downloadbar = Downloadbar:new()
    m:view():addSubview(self.downloadbar.m)

    self.m = m
end

function Depiction:view(m)
    m:view():setBackgroundColor(objc.UIColor:whiteColor())

    if self.deb.installed then
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
            button:setTitle('You sure?')
            function target.onaction()
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
            end
        end
    elseif self.path then
        local label = objc.UILabel:alloc():init()
        label:setFont(objc.UIFont:fontWithName_size('Courier', 12))
        label:setBackgroundColor(objc.UIColor:blackColor())
        label:setTextColor(objc.UIColor:whiteColor())
        label:setNumberOfLines(0)
        label:setText('')
        local function appendtext(s)
            label:setText(objc.tolua(label:text())..s)
            label:sizeToFit()
            label:setFrame{{0, NAVHEIGHT() + namelabel:frame().size.height}, {m:view():frame().size.width, label:frame().size.height}}
        end
        appendtext('$ dpkg -i '..self.deb.Package..'.deb\n')

        local target = ns.target:new()
        local button = objc.UIBarButtonItem:alloc():initWithTitle_style_target_action('Install', UIBarButtonItemStylePlain, target.m, target.sel)
        m:navigationItem():setRightBarButtonItem(button)
        function target.onaction()
            m:view():addSubview(label)
            local oldtoggle = target.onaction
            target.onaction = function() end
            button:setTitle('Installing...')
            local result = ''
            self.deb:install(function(str, status)
                if str == ffi.NULL then
                    if status == 0 then
                        C.alert_display('Installed!', 'Woo!!', 'Dismiss', nil, nil)
                        appendtext('Success! :D')
                        m:navigationItem():setRightBarButtonItem(nil)
                        --POPCONTROLLER()
                        NAV[1] = Deb.List()
                        THE_TABLE:updatefilter()
                        THE_TABLE:refresh()
                    else
                        C.alert_display('Failed', result, 'Dismiss', nil, nil)
                        target.onaction = oldtoggle
                        button:setTitle('Install')
                    end
                else
                    local s = ffi.string(str)
                    appendtext(s)
                    result = result..s
                end
            end)
        end
    end
end

return Depiction
