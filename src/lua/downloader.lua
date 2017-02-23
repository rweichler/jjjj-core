local super = Object
local Downloader = Object.new(super)

function Downloader:new(...)
    local self = super.new(self, ...)

    self.m = self.class:alloc():init()
    objc.Lua(self.m, self)

    return self
end

function Downloader:start()
    local url = objc.NSURL:URLWithString(self.url)
    local downloadRequest = objc.NSURLRequest:requestWithURL(url)
    local sessionConfig = objc.NSURLSessionConfiguration:defaultSessionConfiguration()
    local urlSession = objc.NSURLSession:sessionWithConfiguration_delegate_delegateQueue(sessionConfig, self.m, objc.NSOperationQueue:mainQueue()):retain()
    local downloadTask = urlSession:downloadTaskWithRequest(downloadRequest)
    downloadTask:resume()

    self.session = urlSession
    self.downloadTask = downloadTask
end

function Downloader:handler(url, status, err)
end

Downloader.mname = 'NSObject'
objc.addprotocol('NSURLSessionDownloadDelegate')
Downloader.class = objc.Class(Downloader.mname, 'NSURLSessionTaskDelegate', 'NSURLSessionDelegate', 'NSURLSessionDownloadDelegate')
local class = Downloader.class

objc.addmethod(class, 'URLSession:downloadTask:didFinishDownloadingToURL:', function(self, session, task, url)
    local this = objc.Lua(self)

    local url = objc.tolua(url.description)
    url = string.sub(url, #'file://' + 1, #url)
    this:handler(url)
end, 'v40@0:8@16@24@32')

objc.addmethod(class, 'URLSession:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:', function(self, session, task, data, bytesWritten, totalBytes)
    local this = objc.Lua(self)
    local percent = tonumber(bytesWritten)/tonumber(totalBytes)

    this:handler(nil, percent)
end, 'v56@0:8@16@24Q32Q40Q48')

function class:URLSession_task_didCompleteWithError(self, task, err)
    local this = objc.Lua(self)

    if not(err == ffi.NULL) then
        this:handler(nil, nil, objc.tolua(err.localizedDescription))
    end
end

return Downloader
