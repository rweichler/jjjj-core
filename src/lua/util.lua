ffi.cdef[[
void dpkg_syslog(const char *);
]]
function print(str)
    C.dpkg_syslog(tostring(str))
end

ffi.cdef[[
typedef void DIR;
DIR *opendir(const char *);
int closedir(DIR *dirp);
]]

if ffi.arch == 'arm64' then
    ffi.cdef[[
    struct dirent{
        uint64_t d_ino;
        uint64_t d_seekoff;
        uint16_t d_reclen;
        uint16_t d_namlen;
        uint8_t d_type;
        char d_name[1024];
    };
    struct dirent *readdir(DIR *);
    ]]
    function ls(directory)
        dir = C.opendir(directory)
        if dir == ffi.NULL then return end
        local i = 0
        local t = {}
        local ent = C.readdir(dir)
        while not(ent == ffi.NULL) do
            local name = ffi.string(ent.d_name)
            if not(name == '.' or name == '..') then
                i = i + 1
                t[i] = ffi.string(ent.d_name)
            end
            ent = C.readdir(dir)
        end
        C.closedir(dir)
        return t
    end
else--if ffi.arch == 'armv7' then
    -- this is a hack that stopped working on iOS 10.
    -- i need to port that cdef above to armv7
    function ls(directory)
        local i = 0
        local t = {}
        local f = io.popen('ls '..directory)
        for filename in f:lines() do
            i = i + 1
            t[i] = filename
        end
        f:close()
        return t
    end
end

function isdir(path)
    local dir = C.opendir(path)
    if dir == ffi.NULL then
        return false
    else
        C.closedir(dir)
        return true
    end
end
