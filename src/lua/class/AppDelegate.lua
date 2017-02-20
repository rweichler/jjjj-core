objc.class('AppDelegate', 'UIResponder')
objc.addmethod(objc.AppDelegate, 'application:didFinishLaunchingWithOptions:', function(self, _cmd, app, options)
    local window = objc.UIWindow:alloc():init()
    window:setBackgroundColor(objc.UIColor:redColor())

    local vc = objc.ViewController:alloc():init()
    window:setRootViewController(vc)

    window:makeKeyAndVisible()
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
