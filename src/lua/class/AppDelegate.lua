objc.class('AppDelegate', 'UIResponder')
local class = objc.AppDelegate

objc.addmethod(class, 'application:didFinishLaunchingWithOptions:', function(self, app, options)
    require 'main'
    return true
end, 'B32@0:8@16@24')


objc.addmethod(class, 'application:openURL:sourceApplication:annotation:', function(self, app, url, sourceApp, annotation)
    url = objc.tolua(url.absoluteString)
    url = string.sub(url, #'dpkgapp://' + 1, #url)
    OPENURL(url)


    return true
end, ffi.arch == 'arm64' and 'B48@0:8@16@24@32@40' or 'B24@0:4@8@12@16@20')

objc.addmethod(class, 'applicationWillTerminate:', function(self, app)
    --C.setuid(OLD_UID)
    --C.setgid(OLD_GID)
end, ffi.arch == 'arm64' and 'v24@0:8@16' or 'v12@0:4@8')
