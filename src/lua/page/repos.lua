
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
        for i, repo in ipairs(repos) do
            local function callback()
                local rows = objc.toobj{objc.NSIndexPath:indexPathForRow_inSection(i - 1, 0)}
                tbl.m:reloadRowsAtIndexPaths_withRowAnimation(rows, UITableViewRowAnimationFade)
            end
            repo:getrelease(callback)
            repo:geticon(callback)
        end
        tbl.items = {repos}
        tbl.cell = ui.cell:new()
        tbl.cell.identifier = objc.toobj('sdfoijasd')
        function tbl.cell.onshow(cell, m, section, row)
            local repo = tbl.items[section][row]
            m:textLabel():setText(repo.Origin or repo.Title or repo.url)
            local url = string.gsub(string.gsub(repo.url, 'http://', ''), 'https://', '')
            url = string.sub(url, 1, #url - 1)
            m:detailTextLabel():setText(url)
            m:imageView():setImage(repo.icon or objc.UIImage:imageWithContentsOfFile('/Applications/Cydia.app/unknown.png'))
        end
        tbl:refresh()
    end)
end, 'Repos'))
local path = '/Applications/Cydia.app/install7@2x.png'
REPOCONTROLLER:tabBarItem():setImage(objc.UIImage:imageWithContentsOfFile(path))


table.insert(TABCONTROLLERS, REPOCONTROLLER)
