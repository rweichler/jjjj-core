objc.class('AppDelegate', 'UIResponder')
local class = objc.AppDelegate

local window, vc
objc.addmethod(class, 'application:didFinishLaunchingWithOptions:', function(self, app, options)
    window = objc.UIWindow:alloc():init()
    window:setBackgroundColor(objc.UIColor:whiteColor())

    vc = objc.ViewController:alloc():init()
    window:setRootViewController(vc)

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

    NAV[1] = {
        BACK_BUTTON,
        {
            Name = 'Download',
            select = function(t, k)
                os.execute('rm -f /var/root/TEMP.deb')
                local s, success = os.capture('setuid /usr/bin/wget '..url..' -O /var/root/TEMP.deb')
                C.alert_display(success and 'Done' or 'Failed', s, 'Okay', nil, nil)
                downloaded = true
            end
        },
        {
            Name = 'Install',
            select = function(t, k)
                if not downloaded then
                    C.alert_display('NOPE', 'Need to download first.', 'Okay', nil, nil)
                else
                    local s, success = os.capture('setuid /usr/bin/dpkg -i /var/root/TEMP.deb')
                    s = string.gsub(s, '\n', ' ')
                    C.alert_display(success and 'Done' or 'Failed', s, 'Okay', nil, nil)
                end
            end
        },
    }

    TABLE_VIEW:reloadData()

    return true
end, ffi.arch == 'arm64' and 'B48@0:8@16@24@32@40' or 'B24@0:4@8@12@16@20')

objc.addmethod(class, 'applicationWillTerminate:', function(self, app)
    --C.setuid(OLD_UID)
    --C.setgid(OLD_GID)
end, ffi.arch == 'arm64' and 'v24@0:8@16' or 'v12@0:4@8')
