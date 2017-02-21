objc.class('ViewController', 'UIViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>')
local class = objc.ViewController

local list = Deb.List()
local filtered = list

local stuff = {}
local function sstuff(self)
    local s = tostring(self)
    local r = stuff[s]
    if not r then
        r = {}
        stuff[s] = r
    end
    return r
end

function class:viewDidLoad()
    local tableView = objc.UITableView:alloc():init()
    local frame = objc.UIScreen:mainScreen().bounds
    frame.origin.y = frame.origin.y + 20
    frame.size.height = frame.size.height - 20
    tableView:setFrame(frame)
    tableView:setDelegate(self)
    tableView:setDataSource(self)
    self.view:addSubview(tableView)
    sstuff(self).tableView = tableView

    local searchBar = objc.UISearchBar:alloc():initWithFrame{{0, 0}, {SCREEN.WIDTH, 44}}
    tableView.tableHeaderView = searchBar
    searchBar:setDelegate(self)
    sstuff(self).searchBar = searchBar
end

function class:tableView_numberOfRowsInSection(tableView, section)
    return #filtered
end

function class:scrollViewDidScroll(scrollView)
    local searchBar = sstuff(self).searchBar
    searchBar:resignFirstResponder()
end

local identifier = objc.toobj('lolwuttt')
function class:tableView_cellForRowAtIndexPath(tableView, indexPath)
    local cell = tableView:dequeueReusableCellWithIdentifier(identifier)
    if cell == ffi.NULL then
        cell = objc.UITableViewCell:alloc():initWithStyle_reuseIdentifier(3, identifier)
    end

    local deb = filtered[tonumber(indexPath.row + 1)]

    cell.textLabel:setText(deb.Name or deb.Package)
    cell.detailTextLabel:setText(deb.Description or '')

    return cell
end

local function strfind(s, text)
    local success, found = pcall(string.find, s, text)
    return success and found
end

objc.addmethod(class, 'searchBar:textDidChange:', function(self, searchBar, text)
    text = objc.tolua(text)
    if text == '' then
        filtered = list
    else
        filtered = {}
        for k,v in pairs(list) do
            if strfind(v.Name, text) or strfind(v.Package, text) then
                filtered[#filtered + 1] = v
            end
        end
    end
    sstuff(self).tableView:reloadData()
end, 'v32@0:8@16@24')

objc.addmethod(class, 'searchBarSearchButtonClicked:', function(self, searchBar)
    searchBar:resignFirstResponder()
end, 'v24@0:8@16')

objc.addmethod(class, 'searchBarTextDidBeginEditing:', function(self, searchBar)
    searchBar:setShowsCancelButton_animated(true, true)
end, 'v24@0:8@16')

objc.addmethod(class, 'searchBarTextDidEndEditing:', function(self, searchBar)
    searchBar:setShowsCancelButton_animated(false, true)
end, 'v24@0:8@16')

objc.addmethod(class, 'searchBarCancelButtonClicked:', function(self, searchBar)
    searchBar:resignFirstResponder()
end, 'v24@0:8@16')
