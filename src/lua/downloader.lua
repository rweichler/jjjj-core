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
    local urlSession = objc.NSURLSession:sessionWithConfiguration_delegate_delegateQueue(sessionConfig, delegate, nil)
    local downloadTask = urlSession:downloadTaskWithRequest(downloadRequest)
    downloadTask:resume()

    self.session = urlSession
end


objc.class('DPKGDownloader', 'NSObject<NSURLSessionTaskDelegate>')
local class = objc.DPKGDownloader

function class:URLSession_task_didCompleteWithError(self, session, err)
    local downloader = shit[tostring(self)]
    if downloader then
        print(downloader.url)
        print('ye nigga')
        print(err)
    else
        print('done!!!!')
    end
end


return Downloader
