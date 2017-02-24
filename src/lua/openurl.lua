_G.OPENURL = function(url)
    local progress = objc.UIProgressView:alloc():initWithProgressViewStyle(UIProgressViewStyleDefault)
    progress:setProgress(0)
    PUSHCONTROLLER(function(m)
        m:view():setBackgroundColor(objc.UIColor:whiteColor())
        local padding = 44
        progress:setFrame{{padding,88},{m:view():frame().size.width-padding*2, 22}}
        m:view():addSubview(progress)

        local dl = Downloader:new()
        dl.url = url
        function dl:handler(url, percent, err)
            if err then
                print('WHOA '..err)
            elseif percent then
                progress:setProgress(percent)
            elseif url then
                progress:removeFromSuperview()
                os.capture('setuid /bin/mkdir -p '..CACHE_DIR)
                local path = CACHE_DIR..'/lastinstalled.deb'
                os.capture('setuid /bin/mv '..url..' '..path)
                local target = ns.target:new()
                local button = objc.UIBarButtonItem:alloc():initWithTitle_style_target_action('Install', UIBarButtonItemStylePlain, target.m, target.sel)
                m:navigationItem():setRightBarButtonItem(button)
                function target.onaction()
                    local oldtoggle = target.onaction
                    target.onaction = function() end
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
                                target.onaction = oldtoggle
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





    end, 'Install deb')


end

