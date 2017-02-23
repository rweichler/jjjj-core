objc.class('ViewController', 'UIViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>')
local class = objc.ViewController

function class:viewDidLoad()
    self.view:addSubview(require('main'))
end
