objc.class('AppDelegate', 'UIResponder')

objc.addmethod(objc.AppDelegate, 'application:didFinishLaunchingWithOptions:', function(self, _cmd, app, options)
    self.window = objc.UIWindow:alloc():init()
    self.window:setBackgroundColor(objc.UIColor:redColor())

    local vc = objc.ViewController:alloc():init()
    self.window:setRootViewController(vc)

    self.window:makeKeyAndVisible()
    return true
end, 'B32@0:8@16@24')


local function doit(name)
    --objc.addmethod(objc.AppDelegate, name, function() end, 'v@:@')
end

doit('applicationWillResignActive:')
doit('applicationDidEnterBackground:')
doit('applicationWillEnterForeground:')
doit('applicationDidBecomeActive:')
doit('applicationWillTerminate:')
