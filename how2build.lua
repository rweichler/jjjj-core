local USE_LUCY_SERVER

local deb = debber()
deb.packageinfo = {
    Package = 'jjjj',
    Name = 'jjjj',
    Version = '0.1~alpha4.7.4',
    Architecture = 'iphoneos-arm',
    Depends = 'firmware (>= 5.0), dpkg, bzip2, gzip, cydia, coreutils',
    Depiction = 'http://cydia.r333d.com/view/jjjj',
    Description = 'Repo manager',
    Author = 'r333d <rweichler+cydia@gmail.com>',
    Section = 'Packaging',
}
deb.input = 'layout'
deb.output = 'jjjj.deb'

function info()
    deb:print_packageinfo()
end

local APP_PATH = '/Applications/jjjj.app'
local LUA_PATH = '/var/tweak/com.r333d.jjjj/lua'

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
    b.sflags = '-mios-version-min=7.0'
    b.frameworks = {
        'Foundation',
        'UIKit',
        'CoreGraphics',
        'QuartzCore',
    }
    b.defines = {
        JJJJ_LUA_PATH = '"'..LUA_PATH..'"',
        JJJJ_APP_PATH = '"'..APP_PATH..'"',
    }
    if USE_LUCY_SERVER then
        b.defines[#b.defines + 1] = 'USE_LUCY_SERVER'
    end
    b.libraries = {
        'luajit',
    }
    b.output = 'layout'..APP_PATH..'/jjjj.exe'
    b.cflags = '-fobjc-arc'
    b.cflags = nil
    b.src = table.merge(
        fs.find('src/objc', '*.m'),
        fs.find('src/objc', '*.c')
    )
    b:link(b:compile())
    os.pexecute('cp -r res/app/* layout'..APP_PATH..'/')

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
