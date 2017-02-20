objc.class('ViewController', 'UIViewController <UITableViewDelegate, UITableViewDataSource>')

local list = Pkg.List()

function objc.ViewController:viewDidLoad()
    self.tableView = objc.UITableView:alloc():init()
    local frame = objc.UIScreen:mainScreen().bounds
    frame.origin.y = frame.origin.y + 20
    frame.size.height = frame.size.height - 20
    self.tableView:setFrame(frame)
    self.tableView:setDelegate(self)
    self.tableView:setDataSource(self)
    self.view:addSubview(self.tableView)
end

function objc.ViewController:tableView_numberOfRowsInSection(tableView, section)
    return #list
end

local identifier = objc.toobj('lolwuttt')
function objc.ViewController:tableView_cellForRowAtIndexPath(tableView, indexPath)
    local cell = tableView:dequeueReusableCellWithIdentifier(identifier)
    if cell == ffi.NULL then
        cell = objc.UITableViewCell:alloc():initWithStyle_reuseIdentifier(3, identifier)
    end

    local pkg = list[tonumber(indexPath.row + 1)]

    cell.textLabel:setText(pkg.Name or pkg.Package)
    cell.detailTextLabel:setText(pkg.Name and pkg.Package or '')

    return cell
end

