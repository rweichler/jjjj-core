_G.OPENURL = function(url)
    PUSHCONTROLLER(function(m)
        local depiction = Depiction:new(url)
        depiction:viewdownload(m)
    end, 'Install deb')
end

Downloadbar = Object:new(view)
function Downloadbar:new(frame)
    local self = Object.new(self)

    frame = frame or objc.UIScreen:mainScreen():bounds()

    local view = objc.UIView:alloc():initWithFrame(frame)

    local progress = objc.UIProgressView:alloc():initWithProgressViewStyle(UIProgressViewStyleDefault)
    progress:setProgress(0)

    local padding = 44
    local y = frame.size.height/2
    progress:setFrame{{padding, y},{frame.size.width-padding*2, 22}}

    local downloadingLabel = objc.UILabel:alloc():initWithFrame{{padding, y + 11},{20,20}}
    downloadingLabel:setText('Downloading...')
    downloadingLabel:setFont(downloadingLabel:font():fontWithSize(10))
    downloadingLabel:sizeToFit()

    local percentLabel = objc.UILabel:alloc():initWithFrame{{0, y + 11},{20,20}}
    percentLabel:setText('000%')
    percentLabel:setFont(percentLabel:font():fontWithSize(10))
    percentLabel:sizeToFit()
    local x = progress:frame().origin.x + progress:frame().size.width - percentLabel:frame().size.width
    percentLabel:setFrame{{x, percentLabel:frame().origin.y},percentLabel:frame().size}
    percentLabel:setTextAlignment(NSTextAlignmentRight)
    percentLabel:setText('0%')

    self.m = view
    self.progress = progress
    self.percent = percentLabel
    self.downloading = downloadingLabel

    view:addSubview(self.downloading)
    view:addSubview(self.percent)
    view:addSubview(self.progress)

    return self
end
