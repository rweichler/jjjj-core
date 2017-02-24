_G.OPENURL = function(url)
    local progress = objc.UIProgressView:alloc():initWithProgressViewStyle(UIProgressViewStyleDefault)
    progress:setProgress(0)
    PUSHCONTROLLER(function(m)
        m:view():setBackgroundColor(objc.UIColor:whiteColor())
        local padding = 44
        progress:setFrame{{padding, m:view():frame().size.height/2},{m:view():frame().size.width-padding*2, 22}}
        m:view():addSubview(progress)

        local downloadingLabel = objc.UILabel:alloc():initWithFrame{{padding, progress:frame().origin.y + 11},{20,20}}
        downloadingLabel:setText('Downloading...')
        downloadingLabel:setFont(downloadingLabel:font():fontWithSize(10))
        downloadingLabel:sizeToFit()
        m:view():addSubview(downloadingLabel)

        local percentLabel = objc.UILabel:alloc():initWithFrame{{0, progress:frame().origin.y + 11},{20,20}}
        percentLabel:setText('000%')
        percentLabel:setFont(percentLabel:font():fontWithSize(10))
        percentLabel:sizeToFit()
        local x = progress:frame().origin.x + progress:frame().size.width - percentLabel:frame().size.width
        percentLabel:setFrame{{x, percentLabel:frame().origin.y},percentLabel:frame().size}
        percentLabel:setTextAlignment(NSTextAlignmentRight)
        percentLabel:setText('0%')
        m:view():addSubview(percentLabel)

        local dl = Downloader:new()
        dl.url = url
        function dl:handler(url, percent, err)
            if err then
                print('WHOA '..err)
            elseif percent then
                progress:setProgress(percent)
                percentLabel:setText(math.floor(percent*100 + 0.5)..'%')
            elseif url then
                progress:removeFromSuperview()
                downloadingLabel:removeFromSuperview()
                percentLabel:removeFromSuperview()
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
