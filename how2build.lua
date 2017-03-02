local deb = debber()
deb.packageinfo = {
    Package = 'jjjj',
    Name = 'jjjj (Alpha)',
    Version = '0.1~alpha4.5',
    Architecture = 'iphoneos-arm',
    Depends = 'firmware (>= 5.0), dpkg, bzip2, gzip, cydia, coreutils, luajit',--, ws.hbang.libopener',
    Depiction = 'http://cydia.r333d.com/view/jjjj',
    Description = 'Repo manager',
    Author = 'LUA KING',
    Section = 'Packaging',
}
deb.input = 'layout'
deb.output = 'jjjj.deb'

function info()
    deb:print_packageinfo()
end

local APP_PATH = '/Applications/jjjj.app'
local LUA_PATH = '/var/lua/jjjj.app'

function default()
    os.pexecute("rm -rf layout")

    -- app

    local b = builder('apple')
    b.compiler = 'clang'
    b.sdk = 'iphoneos'
    b.build_dir = 'build'
    b.include_dirs = {
        'deps/include',
        'deps/jetfire',
    }
    b.archs = {
        'armv7',
        'arm64',
    }
    b.library_dirs = {
        'deps/lib',
    }
    b.sflags = '-Fdeps/Frameworks -mios-version-min=7.0'
    b.frameworks = {
        'Foundation',
        'UIKit',
        'CoreGraphics',
        'QuartzCore',
        'CFNetwork',
        'Security',
        --'Opener',
    }
    b.defines = {
        JJJJ_LUA_PATH = '"'..LUA_PATH..'"',
        JJJJ_APP_PATH = '"'..APP_PATH..'"',
    }
    b.libraries = {
        'luajit-5.1.2',
        'substrate',
    }
    b.output = 'layout'..APP_PATH..'/jjjj.exe'
    b.src = fs.find('deps/jetfire', '*.m')
    b.cflags = '-fobjc-arc'
    local jetfire = b:compile()
    b.cflags = nil
    b.src = table.merge(
        fs.find('src/objc', '*.m'),
        fs.find('src/objc', '*.c')
    )
    b:link(table.merge(b:compile(), jetfire))
    os.pexecute('cp -r res/app/* layout'..APP_PATH..'/')

    -- opener
    b.src = table.merge(
        fs.find('src/opener', '*.m'),
        fs.find('src/opener', '*.c')
    )
    b.frameworks = {
        'Opener',
        'Foundation',
    }
    b.output = 'layout/Library/Opener/jjjjOpener.bundle/jjjjOpener'
    b.is_making_dylib = true
    b:link(b:compile())
    b.is_making_dylib = nil
    os.pexecute('cp res/opener/* layout/Library/Opener/jjjjOpener.bundle/')

    -- setuid
    b.frameworks = {}
    b.libraries = {}
    b.src = 'src/setuid/main.c'
    b.output = 'layout'..APP_PATH..'/setuid'
    b:link(b:compile())

    -- Lua

    fs.mkdir('layout/'..LUA_PATH)
    os.pexecute('cp -r src/lua/* layout/'..LUA_PATH)

    fs.mkdir('layout/DEBIAN')
    os.pexecute('cp res/DEBIAN/* layout/DEBIAN/')

    -- res
    os.pexecute('cp -r res/lua layout/'..LUA_PATH..'/res')

    deb:make_deb()
end

function install(iphone)
    iphone = iphone or "iphone"
    os.pexecute('scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null '..deb.output..' '..iphone..':')
    os.pexecute('ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null '..iphone..' "dpkg -i '..deb.output..'; rm '..deb.output..'"')
end

function clean()
    os.pexecute("rm -rf build layout "..deb.output)
end
