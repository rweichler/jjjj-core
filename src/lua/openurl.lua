_G.OPENURL = function(url)
    local progress = objc.UIProgressView:alloc():initWithProgressViewStyle(UIProgressViewStyleDefault)
    progress:setProgress(0)
    local button = ui.button:new()
    button:setTitle('Downloading...')
    PUSHCONTROLLER(function(m)
        m.view:setBackgroundColor(objc.UIColor:whiteColor())
        local padding = 44
        progress:setFrame{{padding,88},{m.view:frame().size.width-padding*2, 22}}
        m.view:addSubview(progress)
        button.m:setFrame{{padding,120},{120,44}}
        m.view:addSubview(button.m)
    end, 'Install deb')


    local dl = Downloader:new()
    dl.url = url
    function dl:handler(url, percent, err)
        if err then
            print('WHOA '..err)
        elseif percent then
            progress:setProgress(percent)
        elseif url then
            os.capture('setuid /bin/mkdir -p '..CACHE_DIR)
            local path = CACHE_DIR..'/lastinstalled.deb'
            os.capture('setuid /bin/mv '..url..' '..path)
            button:setTitle('Install')
            function button:ontoggle()
                local oldtoggle = button.ontoggle
                button:setTitle('Installing...')
                local result = ''
                C.pipeit('setuid /usr/bin/dpkg -i '..path, function(str, status)
                    if str == ffi.NULL then
                        if status == 0 then
                            C.alert_display('Installed!', 'Woo!!', 'Dismiss', nil, nil)
                            POPCONTROLLER()
                            NAV[1] = Deb.List()
                            THE_TABLE:updatefilter()
                            THE_TABLE:refresh()
                        else
                            C.alert_display('Failed', result, 'Dismiss', nil, nil)
                            button.toggle = oldtoggle
                            button:setTitle('Install')
                        end
                    else
                        result = result..ffi.string(str)
                    end
                end)
            end
        end
    end
    dl:start()
end

