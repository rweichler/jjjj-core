
_G.REPOCONTROLLER = objc.UINavigationController:alloc():initWithRootViewController(VIEWCONTROLLER(function(m)
    m:view():setBackgroundColor(objc.UIColor:whiteColor())
    local tbl = ui.table:new()
    tbl.items = {{'Loading...'}}
    tbl.cell = ui.cell:new()
    tbl.cell.identifier = objc.toobj('sdfadsfdd')
    function tbl.cell.onshow(cell, m, section, row)
        local str = tbl.items[section][row]
        m:textLabel():setText(str)
    end
    tbl:refresh()
    tbl.m:setFrame(m:view():bounds())
    m:view():addSubview(tbl.m)

    Repo.List('https://raw.githubusercontent.com/jonluca/MasterRepo/master/masterrepoeasyinstall/etc/apt/sources.list.d/MasterRepo.list', function(repos)
        tbl.items = {repos}
        tbl.cell = ui.cell:new()
        tbl.cell.identifier = objc.toobj('sdfoijasd')
        function tbl.cell.onshow(cell, m, section, row)
            local repo = tbl.items[section][row]
            m:textLabel():setText(repo.url)
        end
        tbl:refresh()
    end)
end, 'Repos'))
local path = '/Applications/Cydia.app/install7@2x.png'
REPOCONTROLLER:tabBarItem():setImage(objc.UIImage:imageWithContentsOfFile(path))


table.insert(TABCONTROLLERS, REPOCONTROLLER)
