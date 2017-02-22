local super = Object
local Downloader = Object.new(super)

function Downloader:new(...)
    local self = super.new(self, ...)

    return self
end

local shit = {}

function Downloader:start()
    local delegate = objc.DPKGDownloader:alloc():init()
    shit[tostring(delegate)] = self

    local url = objc.NSURL:URLWithString(self.url)
    local downloadRequest = objc.NSURLRequest:requestWithURL(url)
    local sessionConfig = objc.NSURLSessionConfiguration:defaultSessionConfiguration()
    local urlSession = objc.NSURLSession:sessionWithConfiguration_delegate_delegateQueue(sessionConfig, delegate, objc.NSOperationQueue:mainQueue()):retain()
    local downloadTask = urlSession:downloadTaskWithRequest(downloadRequest)
    downloadTask:resume()

    self.session = urlSession
    self.downloadTask = downloadTask
end


objc.addprotocol('NSURLSessionDownloadDelegate')
objc.class('DPKGDownloader', 'NSObject<NSURLSessionTaskDelegate, NSURLSessionDelegate, NSURLSessionDownloadDelegate>')
local class = objc.DPKGDownloader

objc.addmethod(class, 'URLSession:downloadTask:didFinishDownloadingToURL:', function(self, session, task, url)
    self = shit[tostring(self)]
    if self.handler then
        local url = objc.tolua(url.description)
        url = string.sub(url, #'file://' + 1, #url)
        self:handler(url)
    end
end, 'v40@0:8@16@24@32')

objc.addmethod(class, 'URLSession:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:', function(self, session, task, data, bytesWritten, totalBytes)
    self = shit[tostring(self)]
    local percent = tonumber(bytesWritten)/tonumber(totalBytes)
    if self.handler then
        self:handler(nil, percent)
    end
end, 'v56@0:8@16@24Q32Q40Q48')

function class:URLSession_task_didCompleteWithError(self, task, err)
    self = shit[tostring(self)]
    if not(err == ffi.NULL) then
        if self.handler then
            self:handler(nil, nil, objc.tolua(err.localizedDescription))
        end
    end
end

return Downloader
