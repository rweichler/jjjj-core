local super = Object
ns.http = Object.new(super)

function ns.http:new(...)
    local self = super.new(self, ...)

    self.m = self.class:alloc():init()
    objc.Lua(self.m, self)

    return self
end

function ns.http:start()
    local url = objc.NSURL:URLWithString(self.url)
    local downloadRequest = objc.NSURLRequest:requestWithURL(url)
    local sessionConfig = objc.NSURLSessionConfiguration:defaultSessionConfiguration()
    local urlSession = objc.NSURLSession:sessionWithConfiguration_delegate_delegateQueue(sessionConfig, self.m, objc.NSOperationQueue:mainQueue()):retain()
    if self.download then
        self.downloadTask = urlSession:downloadTaskWithRequest(downloadRequest)
        self.downloadTask:resume()
    end

    self.session = urlSession
end

function ns.http:handler(url, status, err)
end

ns.http.class = objc.GenerateClass()
local class = ns.http.class

objc.addmethod(class, 'URLSession:downloadTask:didFinishDownloadingToURL:', function(self, session, task, url)
    local this = objc.Lua(self)

    local url = objc.tolua(url:description())
    url = string.sub(url, #'file://' + 1, #url)
    this:handler(url)
end, ffi.arch == 'arm64' and 'v40@0:8@16@24@32' or 'v20@0:4@8@12@16')

objc.addmethod(class, 'URLSession:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:', function(self, session, task, data, bytesWritten, totalBytes)
    local this = objc.Lua(self)
    local percent = tonumber(bytesWritten)/tonumber(totalBytes)

    if not this.totalbytes then
        this.totalbytes = totalBytes
    end
    this:handler(nil, percent)
end, ffi.arch == 'arm64' and 'v56@0:8@16@24Q32Q40Q48' or 'v28@0:4@8@12Q16Q20Q24')

objc.addmethod(class, 'URLSession:task:didCompleteWithError:', function(self, session, task, err)
    local this = objc.Lua(self)

    if err and not(err == ffi.NULL) then
        local desc = err.description
        this:handler(nil, nil, objc.tolua(desc))
    end
end, ffi.arch == 'arm64' and 'v32@0:8@16@24' or 'v16@0:4@8@12')


--- download bar

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

return ns.http
