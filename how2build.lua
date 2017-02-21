local deb = debber()
deb.packageinfo = {
    Package = 'dpkg.app',
    Name = 'dpkg.app',
    Version = '0.1',
    Architecture = 'iphoneos-arm',
    Depends = 'firmware (>= 5.0), mobilesubstrate, luajit',
    Description = 'GUI for dpkg',
    Maintainer = 'r333d <rweichler+cydia+dpkgapp@gmail.com>',
    Author = 'r333d <rweichler+cydia+dpkgapp@gmail.com>',
    Section = 'Tweaks',
}
deb.input = 'layout'
deb.output = 'dpkgapp.deb'

function info()
    deb:print_packageinfo()
end

local LUA_PATH = '/var/lua/dpkg.app'

function default()
    os.pexecute("rm -rf layout")

    -- app

    local b = builder('apple')
    b.compiler = 'clang'
    b.sdk = 'iphoneos'
    b.build_dir = 'build'
    b.include_dirs = {
        'deps/include',
    }
    b.archs = {
        'armv7',
        'arm64',
    }
    b.library_dirs = {
        'deps/lib',
    }
    b.sflags = '-g -mios-version-min=10.0 -Fdeps/Frameworks'
    b.frameworks = {
        'Foundation',
        'UIKit',
        'CoreGraphics',
        'QuartzCore',
        'Opener'
    }
    b.defines = {
        DPKGAPP_LUA_PATH = '"'..LUA_PATH..'"',
    }
    b.libraries = {
        'luajit-5.1.2',
        'substrate',
    }
    b.src = table.merge(
        fs.find('src/objc', '*.m'),
        fs.find('src/objc', '*.c')
    )
    b.output = 'layout/Applications/dpkg.app/dpkg.exe'
    b:link(b:compile())
    os.pexecute('cp -r res/app/* layout/Applications/dpkg.app/')

    -- opener
    b.src = table.merge(
        fs.find('src/opener', '*.m'),
        fs.find('src/opener', '*.c')
    )
    b.frameworks = {
        'Opener',
        'Foundation',
    }
    b.is_making_dylib = true
    b.output = 'layout/Library/Opener/DpkgOpener.bundle/DpkgOpener'
    b:link(b:compile())
    os.pexecute('cp res/opener/* layout/Library/Opener/DpkgOpener.bundle/')

    -- Lua

    fs.mkdir('layout/'..LUA_PATH)
    os.pexecute('cp -r src/lua/* layout/'..LUA_PATH)

    deb:make_deb()
end

function install(iphone)
    iphone = iphone or "iphone"
    os.pexecute('scp '..deb.output..' '..iphone..':')
    os.pexecute('ssh '..iphone..' "dpkg -i '..deb.output..'; rm '..deb.output..'"')
end

function clean()
    os.pexecute("rm -rf build layout "..deb.output)
end
