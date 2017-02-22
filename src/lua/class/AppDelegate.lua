objc.class('AppDelegate', 'UIResponder')
local class = objc.AppDelegate

local window, vc
objc.addmethod(class, 'application:didFinishLaunchingWithOptions:', function(self, app, options)
    window = objc.UIWindow:alloc():init():retain()
    window:setBackgroundColor(objc.UIColor:whiteColor())

    vc = objc.ViewController:alloc():init()
    window:setRootViewController(vc:retain())

    window:makeKeyAndVisible()
    return true
end, 'B32@0:8@16@24')


objc.addmethod(class, 'application:openURL:sourceApplication:annotation:', function(self, app, url, sourceApp, annotation)
    url = objc.tolua(url.absoluteString)
    url = string.sub(url, #'dpkgapp://' + 1, #url)

    for k,v in pairs(NAV) do
        NAV[k] = nil
    end

    local downloaded = false
    local installed = false

    NAV[1] = {
        BACK_BUTTON,
        {
            Name = 'Downloading...',
            select = function(t, k)
                --local s, success = os.capture('setuid /usr/bin/wget '..url..' -O /var/root/TEMP.deb')
                --C.alert_display(success and 'Done' or 'Failed', s, 'Okay', nil, nil)
                --downloaded = true
            end
        },
        {
            Name = 'Install',
            select = function(t, k)
                if not downloaded then
                    C.alert_display('NOPE', 'Need to download first.', 'Okay', nil, nil)
                elseif installed then
                    C.alert_display('NOPE', 'You already installed it!', 'O... okay', nil, nil)
                else

                    local indexPath = objc.NSIndexPath:indexPathForRow_inSection(2, 0)
                    local cell = TABLE_VIEW:cellForRowAtIndexPath(indexPath)
                    t.Name = 'Installing...'
                    cell.textLabel:setText(t.Name)
                    local result = ''
                    C.pipeit('setuid /usr/bin/dpkg -i '..downloaded, function(str, status)
                        if str == ffi.NULL then
                            if status == 0 then
                                installed = true
                                t.Name = 'Installed!!!'
                                os.capture('setuid /bin/rm -f '..downloaded)
                            else
                                t.Name = 'Install failed :('
                                C.alert_display('Failed', result, 'Okay', nil, nil)
                            end

                            local indexPath = objc.NSIndexPath:indexPathForRow_inSection(2, 0)
                            local cell = TABLE_VIEW:cellForRowAtIndexPath(indexPath)
                            cell.textLabel:setText(t.Name)
                        else
                            result = result..ffi.string(str)..'\n'
                        end
                    end)

                    --[[
                    local s, success = os.capture('setuid /usr/bin/dpkg -i '..downloaded)
                    s = string.gsub(s, '\n', ' ')
                    C.alert_display(success and 'Done' or 'Failed', s, 'Okay', nil, nil)
                    ]]
                end
            end
        },
    }

    TABLE_VIEW:reloadData()

    local dl = Downloader:new()
    dl.url = url
    print(dl.url)
    function dl:handler(url, percent, err)
        local t = NAV[1][2]
        if percent then
            t.Name = 'Downloading... '..math.floor(percent*100 + 0.5)..'%'
        elseif url then
            os.capture('setuid /bin/mkdir -p '..CACHE_DIR)
            downloaded = CACHE_DIR..'/lastinstalled.deb'
            os.capture('setuid /bin/mv '..url..' '..downloaded)
            t.Name = 'Downloaded!'
        end
        local indexPath = objc.NSIndexPath:indexPathForRow_inSection(1, 0)
        local cell = TABLE_VIEW:cellForRowAtIndexPath(indexPath)
        cell.textLabel:setText(t.Name)
    end
    dl:start()

    return true
end, ffi.arch == 'arm64' and 'B48@0:8@16@24@32@40' or 'B24@0:4@8@12@16@20')

objc.addmethod(class, 'applicationWillTerminate:', function(self, app)
    --C.setuid(OLD_UID)
    --C.setgid(OLD_GID)
end, ffi.arch == 'arm64' and 'v24@0:8@16' or 'v12@0:4@8')
