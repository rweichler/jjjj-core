
_G.REPOCONTROLLER = objc.UINavigationController:alloc():initWithRootViewController(VIEWCONTROLLER(function(m)
end, 'Repos'))
local path = '/Applications/Cydia.app/install7@2x.png'
REPOCONTROLLER:tabBarItem():setImage(objc.UIImage:imageWithContentsOfFile(path))


table.insert(TABCONTROLLERS, REPOCONTROLLER)
