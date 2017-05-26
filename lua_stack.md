# lua stack introduction
We face two problems when trying to exchange values between Lua and C: the mismatch between a dynamic and a static type system and the mismatch between automatic and manual memory management.


# stack
使用stack完成c和lua的交互，stack的大小自己保护，LUA_MINSTACK默认保证最少20个slots
[lua c api](https://www.lua.org/pil/contents.html#P4)
[doc](https://www.lua.org/pil/24.2.html)
[lua stack 详解](http://blog.csdn.net/yhhwatl/article/details/9303675)

# api
## 依赖 liblua.so
Makefile
TO_LIB中新增liblua.so
src/Makefile中新增
LUA_SO= liblua.so
ALL_T= $(LUA_A) $(LUA_T) $(LUAC_T) $(LUA_SO)
$(LUA_SO): $(CORE_O) $(LIB_O)
    $(CC) -o $@ -shared $? -ldl -lm

## 依赖头文件
lua.h 包含lua的最基本函数lua_open/lua_pcall等
luaauxlib.h 包含以luaL_开头的辅助函数，是由lua.h封装而成的
lualib.h 定义了打开lib的函数

## api解释

lua_open 创建一个新的空白环境，不包含任何函数
使用lua5.2发现编译器找不到lua_open函数，最后发现这个函数在5.2中已经被遗弃，被新的函数luaL_newstate和lua_newstate替代。lua_newstate可自定义内存分配函数，luaL_newstate使用默认的内存分配方式

luaL_loadbuffer 编译lua code为chunk，并将该chunk以匿名函数的形式保存在stack的顶部，不运行

### luaopen_* 基础库

```
    luaopen_base(L);         /* opens the basic library */
    luaopen_table(L);        /* opens the table library */
    luaopen_io(L);           /* opens the I/O library */
    luaopen_string(L);       /* opens the string lib. */
    luaopen_math(L);         /* opens the math lib. */

```

### 函数调用
int lua_pcall (lua_State *L, int nargs, int nresults, int errfunc);

```
lua_getglobal(L, "func");
lua_pushnumber(L, x);
lua_pushnumber(L, y);

if (lua_pcall(L, 2, 1, 0) != 0)

```

### push elements
```
    void lua_pushnil (lua_State *L);
    void lua_pushboolean (lua_State *L, int bool);
    void lua_pushnumber (lua_State *L, double n);
    void lua_pushlstring (lua_State *L, const char *s,
                                        size_t length);
    void lua_pushstring (lua_State *L, const char *s);
```

lua stack: LUA_MINSTACK，大小自己保证
int lua_checkstack (lua_State *L, int sz); 返回值是1或者0表示是否有sz大小的空间

### query elements
判断类型
int lua_is... (lua_State *L, int index);

查询
```
    int            lua_toboolean (lua_State *L, int index);
    double         lua_tonumber (lua_State *L, int index);
    const char    *lua_tostring (lua_State *L, int index);
    size_t         lua_strlen (lua_State *L, int index);
```
### other stack operations

```
    int   lua_gettop (lua_State *L);
    void  lua_settop (lua_State *L, int index);
    void  lua_pushvalue (lua_State *L, int index);
    void  lua_remove (lua_State *L, int index);
    void  lua_insert (lua_State *L, int index);
    void  lua_replace (lua_State *L, int index);
```

### table operations
获取表中元素
```
    lua_getglobal(pl, "my_tb");
    lua_pushstring(pl, "my_name");
    lua_gettable(pl, -2);

```

设置表中元素
```
    lua_getglobal(pl, "my_tb");
    lua_pushstring(pl, "my_age");
    lua_gettable(pl, -2);
```

### lua 调用c ，不实用register，直接返回register表，同时使用metadatatable

lua调用c的每一次函数调用，都是创建一个完全新的lua_State参数，也就是说，即使引用
lua的表中的函数，lua_State仅仅是作为参数，并不是指包含了原来表的lua_State

require函数，会调用luaopen_libname方法，返回值为栈顶的第一个数值

```
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

int add(lua_State *L)
{
    int x, y;
    x = luaL_checknumber(L, 1);
    y = luaL_checknumber(L, 2);

    lua_pushnumber(L,x+y);

    return 1;
}

int sub(lua_State *L)
{
    int x, y;
    x = luaL_checknumber(L, 1);
    y = luaL_checknumber(L, 2);

    lua_pushnumber(L,x-y);

    return 1;
}

int luaopen_lua_call_c(lua_State* L) {

    luaL_newmetatable(L, "testmeta");
    lua_pushvalue(L, -1);
    lua_setfield(L, -2, "__index");

    lua_pushcfunction(L, sub);
    lua_setfield(L, -2, "sub");

    lua_pop(L, 1);

    lua_newtable(L);

    lua_pushcfunction(L, add);
    lua_setfield(L, -2, "add");

    luaL_getmetatable(L, "testmeta");
    lua_setmetatable(L, -2);

    return 1;
}
```
