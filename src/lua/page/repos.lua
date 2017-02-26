
_G.REPOCONTROLLER = objc.UINavigationController:alloc():initWithRootViewController(VIEWCONTROLLER(function(m)
    m:view():setBackgroundColor(objc.UIColor:whiteColor())
    local target = ns.target:new()
    local button = objc.UIBarButtonItem:alloc():initWithTitle_style_target_action('Do it', UIBarButtonItemStylePlain, target.m, target.sel)
    m:navigationItem():setRightBarButtonItem(button)

    function target.onaction()
        Repo.List('https://raw.githubusercontent.com/jonluca/MasterRepo/master/masterrepoeasyinstall/etc/apt/sources.list.d/MasterRepo.list', function(repos)
            print(#repos)
        end)
    end
end, 'Repos'))
local path = '/Applications/Cydia.app/install7@2x.png'
REPOCONTROLLER:tabBarItem():setImage(objc.UIImage:imageWithContentsOfFile(path))


table.insert(TABCONTROLLERS, REPOCONTROLLER)
