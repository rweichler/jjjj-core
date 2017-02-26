local super = Object
local Depiction = Object.new(super)

function Depiction:new(arg1)
    local self = super.new(self)

    if type(arg1) == 'table' then
        self.deb = arg1
    elseif type(arg1) == 'string' then
        local url = arg1
        self:startdownload(url)
    end

    return self
end

function Depiction:startdownload(url)
    print('Downloading from '..url)
    self.deb = Deb:newfromurl(url, function(errcode)
        if errcode then
            C.alert_display('Could not download deb', 'Got '..errcode.. ' HTTP error', 'Dismiss', nil, nil)
            POPCONTROLLER()
        else
            self:ondownloadcomplete()
        end
    end, function(percent)
        local dl = self.downloadbar
        dl.progress:setProgress(percent)
        dl.percent:setText(math.floor(percent*100 + 0.5)..'%')
    end)
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

    self:view(m)
end

function Depiction:viewdownload(m)
    m:view():setBackgroundColor(objc.UIColor:whiteColor())

    self.downloadbar = Downloadbar:new()
    m:view():addSubview(self.downloadbar.m)

    self.m = m
end

function Depiction:view(m)
    m:view():setBackgroundColor(objc.UIColor:whiteColor())

    local url = self.deb.Depiction or 'http://cydia.saurik.com/package/'..self.deb.Package
    local webview = objc.UIWebView:alloc():initWithFrame(m:view():bounds())
    local request = objc.NSURLRequest:requestWithURL(objc.NSURL:URLWithString(url))
    webview:loadRequest(request)

    m:view():addSubview(webview)

    local label = objc.UILabel:alloc():init()
    label:setFont(objc.UIFont:fontWithName_size('Courier', 12))
    label:setBackgroundColor(objc.UIColor:blackColor())
    label:setTextColor(objc.UIColor:whiteColor())
    label:setNumberOfLines(0)
    label:setText('')
    label:setAlpha(0.7)
    label:setUserInteractionEnabled(false)
    local function appendtext(s)
        if s == true then
            local label2 = objc.UILabel:alloc():init()
            label2:setFont(label:font())
            label2:setAlpha(0.7)
            label2:setUserInteractionEnabled(false)
            label2:setBackgroundColor(label:backgroundColor())
            label2:setTextColor(objc.UIColor:greenColor())
            label2:setText('Success! :D')
            label2:sizeToFit()
            label2:setFrame{{0, NAVHEIGHT() + label:frame().size.height},{m:view():frame().size.width, label2:frame().size.height}}
            m:view():addSubview(label2)
            ANIMATE(1, 1, function(finished)
                if finished == nil then
                    label:setAlpha(0)
                    label2:setAlpha(0)
                elseif finished then
                    label2:removeFromSuperview()
                    label:setAlpha(0.7)
                    label:setText('')
                    label:sizeToFit()
                end
            end)
            return
        end
        label:setText(objc.tolua(label:text())..s)
        label:sizeToFit()
        label:setFrame{{0, NAVHEIGHT()}, {m:view():frame().size.width, label:frame().size.height}}
    end
    m:view():addSubview(label)

    self:addbutton(m, appendtext)
end

function Depiction:addbutton(m, appendtext)
    if self.deb.installed then

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

                appendtext('$ dpkg --remove '..self.deb.Package..'\n')

                self.deb:uninstall(function(line, status)
                    if line == ffi.NULL then
                        if status == 0 then
                            m:navigationItem():setRightBarButtonItem(nil)
                            --POPCONTROLLER()
                            appendtext(true)
                            Deb.UpdateList()
                            self:addbutton(m, appendtext)
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
    elseif self.deb.path then

        local target = ns.target:new()
        local button = objc.UIBarButtonItem:alloc():initWithTitle_style_target_action('Install', UIBarButtonItemStylePlain, target.m, target.sel)
        m:navigationItem():setRightBarButtonItem(button)
        function target.onaction()
            appendtext('$ dpkg -i '..self.deb.Package..'.deb\n')
            local oldtoggle = target.onaction
            target.onaction = function() end
            button:setTitle('Installing...')
            local result = ''
            self.deb:install(function(str, status)
                if str == ffi.NULL then
                    if status == 0 then
                        appendtext(true)
                        m:navigationItem():setRightBarButtonItem(nil)
                        --POPCONTROLLER()
                        Deb.UpdateList()
                        self:addbutton(m, appendtext)
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
    elseif self.deb.Filename and self.deb.repo then
        local target = ns.target:new()
        local button = objc.UIBarButtonItem:alloc():initWithTitle_style_target_action('Download', UIBarButtonItemStylePlain, target.m, target.sel)
        m:navigationItem():setRightBarButtonItem(button)
        function target.onaction()
            if not(string.sub(self.deb.Filename, 1, 2) == './') then
                C.alert_display('NOPE', 'NOPE', 'Dismiss', nil, nil)
                return
            end
            local url = self.deb.repo.url..string.sub(self.deb.Filename, 3, #self.deb.Filename)
            m:navigationItem():setRightBarButtonItem(nil)
            self:viewdownload(m)
            self:startdownload(url)
        end
    end
end

return Depiction
