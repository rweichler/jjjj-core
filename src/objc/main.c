#include <lua/lua.h>
#include <lua/lauxlib.h>
#include <lua/lualib.h>
#include <stdbool.h>
#include <syslog.h>
#include <sys/types.h>
#include <unistd.h>
#include <string.h>

#define LOG_PREFIX "jjjjlua"
#define log(fmt, ...) syslog(LOG_WARNING, LOG_PREFIX": "fmt, ## __VA_ARGS__)

// TODO: figure out why i cant just call syslog through the ffi (probably easy)
void dpkg_syslog(const char *str)
{
    log("%s", str);
}

// TODO: move traceback stuff into Lua and wrap init.lua in an xpcall (easy)
static int l_traceback(lua_State *L) {
    lua_getfield(L, LUA_GLOBALSINDEX, "debug");
    lua_getfield(L, -1, "traceback");
    lua_pushvalue(L, 1);
    lua_pushinteger(L, 2);
    lua_call(L, 2, 1);
    return 1;
}

// TODO: remove main, and have the bundle executable be a Lua script (with #!/usr/bin/env luajit at the top), which
// then loads all of the necessary C libs (medium difficulty? idk.)
int main(int argc, char *argv[])
{
    bool success;

    lua_State *L = luaL_newstate();
    luaL_openlibs(L);
    lua_pushcfunction(L, l_traceback);

#ifdef USE_LUCY_SERVER
    void server_start();
    void start_lua(lua_State *);
    server_start();
    start_lua(L);
#endif

    lua_pushstring(L, JJJJ_LUA_PATH);
    lua_setglobal(L, "PATH");
    lua_pushstring(L, JJJJ_APP_PATH);
    lua_setglobal(L, "APP_PATH");
    success = luaL_loadfile(L, JJJJ_LUA_PATH"/init.lua") == 0;
    if(!success) {
        log("Lua error: %s", lua_tostring(L, -1));
        return 1;
    }
    lua_pushnumber(L, argc);
    lua_pushlightuserdata(L, argv);
    success = lua_pcall(L, 2, 1, 1) == 0;
    if(!success) {
        // this is so i can do
        // ondeviceconsole | grep jjjj
        // and have it still get newlines
        const char *err = lua_tostring(L, -1);
        static const char *repl = "\n"LOG_PREFIX":  ";
        char buf[strlen(err)*strlen(repl) + 1];
        buf[0] = '\0';
        for(int i = 0; i < strlen(err); i++) {
            char c = err[i];
            if(c == '\n') {
                strcat(buf, repl);
            } else {
                int ibuf = strlen(buf);
                buf[ibuf] = c;
                buf[ibuf + 1] = '\0';
            }
        }
        log("Lua error: %s", buf);
        return 1;
    }
    int result = lua_tonumber(L, -1);
    lua_pop(L, 2);
    lua_close(L);
    return result;
}
