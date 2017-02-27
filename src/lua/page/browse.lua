

_G.BROWSECONTROLLER = objc.UINavigationController:alloc():initWithRootViewController(VIEWCONTROLLER(function(m)
    m:view():setBackgroundColor(objc.UIColor:whiteColor())

    local url = 'http://reddit.com/r/iOS_Jailbreak'
    local webview = objc.UIWebView:alloc():initWithFrame(m:view():bounds())
    local request = objc.NSURLRequest:requestWithURL(objc.NSURL:URLWithString(url))
    webview:loadRequest(request)
    m:view():addSubview(webview)
end, 'Browse'))
local path = RES_PATH..'/globe.png'
BROWSECONTROLLER:tabBarItem():setImage(objc.UIImage:imageWithContentsOfFile(path))

table.insert(TABCONTROLLERS, BROWSECONTROLLER)
