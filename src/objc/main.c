#include <lua/lua.h>
#include <lua/lauxlib.h>
#include <lua/lualib.h>
#include <stdbool.h>
#include <syslog.h>
#include <sys/types.h>
#include <unistd.h>

void dpkg_syslog(const char *str)
{
    syslog(LOG_WARNING, "deepkg.app: %s", str);
}

int main(int argc, char *argv[])
{
    bool success;

    lua_State *L = luaL_newstate();
    luaL_openlibs(L);
    lua_pushstring(L, DPKGAPP_LUA_PATH);
    lua_setglobal(L, "PATH");
    success = luaL_loadfile(L, DPKGAPP_LUA_PATH"/init.lua") == 0;
    if(!success) {
        syslog(LOG_WARNING, "deepkg.app: Lua error: %s", lua_tostring(L, -1));
        return 1;
    }
    lua_pushnumber(L, argc);
    lua_pushlightuserdata(L, argv);
    success = lua_pcall(L, 2, 1, 0) == 0;
    if(!success) {
        syslog(LOG_WARNING, "deepkg.app: Lua error: %s", lua_tostring(L, -1));
        return 1;
    }
    int result = lua_tonumber(L, -1);
    lua_pop(L, 1);
    lua_close(L);
    return result;
}
