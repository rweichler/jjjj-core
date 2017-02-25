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
                local deb = Deb:new(path)
                local namelabel = objc.UILabel:alloc():init()
                namelabel:setFrame{{0, NAVHEIGHT()},{60,44}}
                namelabel:setText(deb.Name or deb.Package)
                namelabel:sizeToFit()
                m:view():addSubview(namelabel)


                local label = objc.UILabel:alloc():init()
                label:setFont(objc.UIFont:fontWithName_size('Courier', 12))
                label:setBackgroundColor(objc.UIColor:blackColor())
                label:setTextColor(objc.UIColor:whiteColor())
                label:setNumberOfLines(0)
                label:setText('')
                local function appendtext(s)
                    label:setText(objc.tolua(label:text())..s)
                    label:sizeToFit()
                    label:setFrame{{0, NAVHEIGHT() + namelabel:frame().size.height}, {m:view():frame().size.width, label:frame().size.height}}
                end
                appendtext('$ dpkg -i '..deb.Package..'.deb\n')

                local target = ns.target:new()
                local button = objc.UIBarButtonItem:alloc():initWithTitle_style_target_action('Install', UIBarButtonItemStylePlain, target.m, target.sel)
                m:navigationItem():setRightBarButtonItem(button)
                function target.onaction()
                    m:view():addSubview(label)
                    local oldtoggle = target.onaction
                    target.onaction = function() end
                    button:setTitle('Installing...')
                    local result = ''
                    deb:install(function(str, status)
                        if str == ffi.NULL then
                            if status == 0 then
                                C.alert_display('Installed!', 'Woo!!', 'Dismiss', nil, nil)
                                appendtext('Success! :D')
                                m:navigationItem():setRightBarButtonItem(nil)
                                --POPCONTROLLER()
                                NAV[1] = Deb.List()
                                THE_TABLE:updatefilter()
                                THE_TABLE:refresh()
                            else
                                C.alert_display('Failed', result, 'Dismiss', nil, nil)
                                target.onaction = oldtoggle
                                button:setTitle('Install')
                            end
                        else
                            local s = ffi.string(str)
                            appendtext(s)
                            result = result..s
                        end
                    end)
                end
            end
        end
        dl:start()
    end, 'Install deb')
end
