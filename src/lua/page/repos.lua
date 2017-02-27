
local function PUSHCONTROLLER(f, title)
    REPOCONTROLLER:pushViewController_animated(VIEWCONTROLLER(f, title), true)
end

_G.REPOCONTROLLER = objc.UINavigationController:alloc():initWithRootViewController(VIEWCONTROLLER(function(m)
    m:view():setBackgroundColor(objc.UIColor:whiteColor())
    local tbl = ui.table:new()
    tbl.items = {{'Loading...'}}
    tbl.cell = ui.cell:new()
    tbl:refresh()
    tbl.m:setFrame(m:view():bounds())
    m:view():addSubview(tbl.m)

    Repo.List(MASTER_REPO_LIST, function(repos)
        for i, repo in ipairs(repos) do
            local function callback()
                local rows = objc.toobj{objc.NSIndexPath:indexPathForRow_inSection(i - 1, 0)}
                tbl.m:reloadRowsAtIndexPaths_withRowAnimation(rows, UITableViewRowAnimationNone)
            end
            repo:getrelease(callback)
            repo:geticon(callback)
        end
        tbl.items = {repos}
        tbl.cell = ui.cell:new()
        function tbl.cell.onshow(cell, m, section, row)
            local repo = tbl.items[section][row]
            m:textLabel():setText(repo.Origin or repo.Title or repo.prettyurl)
            m:detailTextLabel():setText(repo.prettyurl)
            m:imageView():setImage(repo.icon or objc.UIImage:imageWithContentsOfFile('/Applications/Cydia.app/unknown.png'))
        end
        function tbl.cell.onselect(cell, section, row)
            local repo = tbl.items[section][row]
            local tbl = ui.table:new()
            tbl.items = {{'Loading...'}}
            tbl.cell = ui.cell:new()
            tbl:refresh()

            repo:getpackages(function()
                tbl.items = {repo.debs}
                tbl.cell = ui.cell:new()
                function tbl.cell.onshow(cell, m, section, row)
                    local deb = tbl.items[section][row]
                    m:textLabel():setText(deb.Name or deb.Package)
                    m:detailTextLabel():setText(deb.Description)

                    local img = nil
                    if deb.Section then
                        local path = '/Applications/Cydia.app/Sections/'..string.gsub(deb.Section, ' ', '_')..'.png'
                        local f = io.open(path, 'r')
                        if f then
                            f:close()
                        else
                            img = repo.icon
                            path = '/Applications/Cydia.app/unknown.png'
                        end
                        img = img or objc.UIImage:imageWithContentsOfFile(path)
                    end

                    m:imageView():setImage(img)
                end
                function tbl.cell.onselect(cell, section, row)
                    local depiction = Depiction:new()
                    depiction.deb = tbl.items[section][row]
                    PUSHCONTROLLER(function(m)
                        depiction:view(m)
                    end, depiction:gettitle())
                end
                tbl:refresh()
            end)

            PUSHCONTROLLER(function(m)
                m:view():setBackgroundColor(objc.UIColor:whiteColor())
                tbl.m:setFrame(m:view():bounds())
                m:view():addSubview(tbl.m)
            end, repo.Origin or repo.Title or repo.prettyurl)
        end
        tbl:refresh()
    end)
end, 'Repos'))
local path = '/Applications/Cydia.app/install7@2x.png'
REPOCONTROLLER:tabBarItem():setImage(objc.UIImage:imageWithContentsOfFile(path))


table.insert(TABCONTROLLERS, REPOCONTROLLER)
