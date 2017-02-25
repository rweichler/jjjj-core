#include <lua/lua.h>
#include <lua/lauxlib.h>
#include <lua/lualib.h>
#include <stdbool.h>
#include <syslog.h>
#include <sys/types.h>
#include <unistd.h>
#include <string.h>

#define LOG_PREFIX "deepkg.app"
#define log(fmt, ...) syslog(LOG_WARNING, LOG_PREFIX": "fmt, ## __VA_ARGS__)

void dpkg_syslog(const char *str)
{
    log("%s", str);
}

static int l_traceback(lua_State *L) {
    lua_getfield(L, LUA_GLOBALSINDEX, "debug");
    lua_getfield(L, -1, "traceback");
    lua_pushvalue(L, 1);
    lua_pushinteger(L, 2);
    lua_call(L, 2, 1);
    return 1;
}

int main(int argc, char *argv[])
{
    bool success;

    lua_State *L = luaL_newstate();
    luaL_openlibs(L);
    lua_pushcfunction(L, l_traceback);

    lua_pushstring(L, DPKGAPP_LUA_PATH);
    lua_setglobal(L, "PATH");
    success = luaL_loadfile(L, DPKGAPP_LUA_PATH"/init.lua") == 0;
    if(!success) {
        log("Lua error: %s", lua_tostring(L, -1));
        return 1;
    }
    lua_pushnumber(L, argc);
    lua_pushlightuserdata(L, argv);
    success = lua_pcall(L, 2, 1, 1) == 0;
    if(!success) {
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
