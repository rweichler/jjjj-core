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
]]

function CGRectMake(x, y, w, h)
    local rect = ffi.new('struct CGRect')
    rect.origin.x = x
    rect.origin.y = y
    rect.size.width = w
    rect.size.height = h
    return rect
end
