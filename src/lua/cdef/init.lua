if ffi.arch == 'arm64' then
    ffi.cdef'typedef double CGFloat;'
else
    ffi.cdef'typedef float CGFloat;'
end

ffi.cdef[[
struct CGPoint {
    CGFloat x;
    CGFloat y;
};
struct CGSize {
    CGFloat width;
    CGFloat height;
};
struct CGRect {
    struct CGPoint origin;
    struct CGSize size;
};
int UIApplicationMain(int argc, char **argv, id principalClassName, id appDelegateClassName);
typedef uint32_t uid_t;
typedef uint32_t gid_t;
int setuid(uid_t uid);
int setgid(gid_t gid);

typedef void (*alert_callback_t)();
typedef void (*alert_input_callback_t)(const char *response);
void alert_display(const char *title, const char *msg, const char *cancel, const char *ok, alert_callback_t callback);
void alert_input(const char *title, const char *msg, const char *cancel, const char *ok, alert_input_callback_t callback);
]]

function CGRectMake(x, y, w, h)
    local rect = ffi.new('struct CGRect')
    rect.origin.x = x
    rect.origin.y = y
    rect.size.width = w
    rect.size.height = h
    return rect
end

ffi.metatype('struct CGRect', {
    __tostring = function(t)
        return '<CGRect ('..t.origin.x..', '..t.origin.y..', '..t.size.width..', '..t.size.height..')>'
    end,
})
