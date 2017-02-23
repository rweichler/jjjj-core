_G.BACK_BUTTON = {
    Name = '<-- back',
    select = function(self, nav)
        nav[#nav] = nil
        nav[1] = Deb.List()
        return true
    end,
}

local nav = {}
_G.NAV = nav
local lastfiltered
local filtered
local function list()
    if filtered then
        if lastfiltered == nav[#nav] then
            return filtered
        else
            filtered = nil
        end
    end
    lastfiltered = nil
    return nav[#nav]
end

local function filter(t)
    filtered = t
    if filtered then
        lastfiltered = nav[#nav]
    else
        lastfiltered = nil
    end
end

nav[#nav + 1] = Deb.List()


local table = ui.table:new()
table.items = {}
function table:onscroll(x, y)
    self.searchbar.m:resignFirstResponder()
end

table.cell = ui.cell:new()
table.cell.identifier = objc.toobj('lolwatttt')


function table:refresh(...)
    self.items[1] = list()
    ui.table.refresh(self, ...)
end
function table.cell:onselect(section, row)
    local deb = table.items[section][row]
    if deb and deb.select then
        if deb:select(nav) then
            table:refresh()
        end
    end
end
function table.cell:mnew()
    return objc.UITableViewCell:alloc():initWithStyle_reuseIdentifier(3, self.identifier)
end
function table.cell:onshow(m, section, row)
    local deb = table.items[section][row]
    if not deb then return end

    local img = nil
    if deb.Section then
        local path = '/Applications/Cydia.app/Sections/'..string.gsub(deb.Section, ' ', '_')..'.png'
        local f = io.open(path, 'r')
        if f then
            f:close()
            img = objc.UIImage:imageWithContentsOfFile(path)
        end
    end

    m.imageView:setImage(img)
    m.textLabel:setText(deb.Name or deb.Package)
    m.detailTextLabel:setText(deb.Description or '')
end
table:refresh()

table.searchbar = ui.searchbar:new()
table.searchbar.m:setFrame{{0, 0}, {SCREEN.WIDTH, 44}}
table.m.tableHeaderView = table.searchbar.m

local function strfind(s, text)
    if not s or not text then return end
    return string.find(string.lower(s), string.lower(text))
end
function table.searchbar:ontextchange(text)
    if text == '' then
        filter(nil)
    else
        local t = {}
        for k,v in pairs(nav[#nav]) do
            if strfind(v.Name, text) or strfind(v.Package, text) then
                t[#t + 1] = v
            end
        end
        filter(t)
    end
    table:refresh()
end

_G.THE_TABLE = table

local window = objc.UIWindow:alloc():init():retain()

local vc = VIEWCONTROLLER(function(self)
    table.m:setFrame{{0, 0}, {self.view:frame().size.width, self.view:frame().size.height}}
    self.view:addSubview(table.m)
end)

_G.NAVCONTROLLER = objc.UINavigationController:alloc():initWithRootViewController(vc)
window:setRootViewController(NAVCONTROLLER:retain())
window:makeKeyAndVisible()

_G.OPENURL = function(url)
    for k,v in pairs(NAV) do
        NAV[k] = nil
    end

    local downloaded = false
    local installed = false

    NAV[1] = {
        BACK_BUTTON,
        {
            Name = 'Downloading...',
            select = function(t, k)
                --local s, success = os.capture('setuid /usr/bin/wget '..url..' -O /var/root/TEMP.deb')
                --C.alert_display(success and 'Done' or 'Failed', s, 'Okay', nil, nil)
                --downloaded = true
            end
        },
        {
            Name = 'Install',
            select = function(t, k)
                if not downloaded then
                    C.alert_display('NOPE', 'Need to download first.', 'Okay', nil, nil)
                elseif installed then
                    C.alert_display('NOPE', 'You already installed it!', 'O... okay', nil, nil)
                else

                    --local indexPath = objc.NSIndexPath:indexPathForRow_inSection(2, 0)
                    --local cell = TABLE_VIEW:cellForRowAtIndexPath(indexPath)
                    local cell = THE_TABLE:getmcell(1, 2)
                    t.Name = 'Installing...'
                    cell.textLabel:setText(t.Name)
                    local result = ''
                    C.pipeit('setuid /usr/bin/dpkg -i '..downloaded, function(str, status)
                        if str == ffi.NULL then
                            if status == 0 then
                                installed = true
                                t.Name = 'Installed!!!'
                                os.capture('setuid /bin/rm -f '..downloaded)
                            else
                                t.Name = 'Install failed :('
                                C.alert_display('Failed', result, 'Okay', nil, nil)
                            end

                            --local indexPath = objc.NSIndexPath:indexPathForRow_inSection(2, 0)
                            --local cell = TABLE_VIEW:cellForRowAtIndexPath(indexPath)
                            local cell = THE_TABLE:getmcell(1, 2)
                            cell.textLabel:setText(t.Name)
                        else
                            result = result..ffi.string(str)..'\n'
                        end
                    end)

                    --[[
                    local s, success = os.capture('setuid /usr/bin/dpkg -i '..downloaded)
                    s = string.gsub(s, '\n', ' ')
                    C.alert_display(success and 'Done' or 'Failed', s, 'Okay', nil, nil)
                    ]]
                end
            end
        },
    }

    THE_TABLE:refresh()

    local dl = Downloader:new()
    dl.url = url
    print(dl.url)
    function dl:handler(url, percent, err)
        local t = NAV[1][2]
        if percent then
            t.Name = 'Downloading... '..math.floor(percent*100 + 0.5)..'%'
        elseif url then
            os.capture('setuid /bin/mkdir -p '..CACHE_DIR)
            downloaded = CACHE_DIR..'/lastinstalled.deb'
            os.capture('setuid /bin/mv '..url..' '..downloaded)
            t.Name = 'Downloaded!'
        end
        local cell = THE_TABLE:getmcell(1, 2)
        --local indexPath = objc.NSIndexPath:indexPathForRow_inSection(1, 0)
        --local cell = TABLE_VIEW:cellForRowAtIndexPath(indexPath)
        cell.textLabel:setText(t.Name)
    end
    dl:start()
end
