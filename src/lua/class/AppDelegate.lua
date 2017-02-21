objc.class('AppDelegate', 'UIResponder')
local class = objc.AppDelegate

objc.addmethod(class, 'application:didFinishLaunchingWithOptions:', function(self, app, options)
    self.window = objc.UIWindow:alloc():init()
    self.window:setBackgroundColor(objc.UIColor:redColor())

    local vc = objc.ViewController:alloc():init()
    self.window:setRootViewController(vc)

    self.window:makeKeyAndVisible()
    return true
end, 'B32@0:8@16@24')


objc.addmethod(class, 'application:openURL:sourceApplication:annotation:', function(self, app, url, sourceApp, annotation)
    print(url)
    return true
end, 'B48@0:8@16@24@32@40')
