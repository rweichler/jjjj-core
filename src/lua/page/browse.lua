

_G.BROWSECONTROLLER = objc.UINavigationController:alloc():initWithRootViewController(VIEWCONTROLLER(function(m)
end, 'Browse'))
local path = RES_PATH..'/globe.png'
BROWSECONTROLLER:tabBarItem():setImage(objc.UIImage:imageWithContentsOfFile(path))

table.insert(TABCONTROLLERS, BROWSECONTROLLER)
