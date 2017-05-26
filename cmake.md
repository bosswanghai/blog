# CMake

### 简介

CMake”这个名字是"cross platform make"的缩写。

CMake是个开源的跨平台，配置文件取名为CMakeLists.txt，用来产生标准的构建文件，如 Unix 的 Makefile 或Windows Visual C++ 的 projects/workspaces。

CMake支持in-place建构（二进档和源代码在同一个目录树中）和out-of-place建构（二进档在别的目录里），因此可以很容易从同一个源代码目录树中建构出多个二进档。

### 使用流程

1. linux平台使用cmake的过程

编写 CmakeLists.txt。

执行命令“cmake PATH”或者“ccmake PATH”生成 Makefile ( PATH 是 CMakeLists.txt 所在的目录 )。

使用 make 命令进行编译。

2. 构建main.cpp

```
 #include<iostream>

 int main()
 {
     std::cout<<"Hello word!"<<std::endl;
     return 0;
 }

```

3. 手动编写CMakeList.txt

```

PROJECT (HELLO)
SET(SRC_LIST main.c)
# or AUX_SOURCE_DIRECTORY(. DIR_SRCS)
ADD_SUBDIRECTORY(./src) # 将当前src子目录添加到编译环境中，并执行子目录中的CMakeList.txt
MESSAGE(STATUS "This is BINARY dir " ${HELLO_BINARY_DIR})
MESSAGE(STATUS "This is SOURCE dir "${HELLO_SOURCE_DIR})
ADD_EXECUTABLE(hello ${SRC_LIST})
TARGET_LINK_LIBRARIES(main Test) # 将test库进行链接


## 将子目录中的库编译为共享库
AUX_SOURCE_DIRECTORY(. DIR_TEST1_SRCS)
ADD_LIBRARY ( Test ${DIR_TEST1_SRCS})
```

安装位置

```

生成的Makefile里面
DESTDIR=
install:

直接make install安装到/usr/lib，make install DESTDIR=/tmp/dir安装到指定目录

更复杂的需要指定prefix

cmake -DCMAKE_INSTALL_PREFIX=/usr .

CMAKE_INSTALL_PREFIX 的默认定义是/usr/local
```


具体安装指令

```

INSTALL(TARGETS targets...
 [[ARCHIVE|LIBRARY|RUNTIME]
 [DESTINATION <dir>]
 [PERMISSIONS permissions...]
 [CONFIGURATIONS
 [Debug|Release|...]]
 [COMPONENT <component>]
 [OPTIONAL]
 ] [...])


INSTALL指令也可以指定安装目录

```


头文件搜索路径

```
INCLUDE_DIRECTORIES([AFTER|BEFORE] [SYSTEM] dir1 dir2 ...)

```

为 target 添加共享库

```
LINK_DIRECTORIES(directory1 directory2 ...)

```

特殊的环境变量 CMAKE_INCLUDE_PATH 和 CMAKE_LIBRARY_PATH
务必注意，这两个是环境变量而不是 cmake 变量。


### CMake常用变量

```
1，CMAKE_BINARY_DIR
 PROJECT_BINARY_DIR
 <projectname>_BINARY_DIR
这三个变量指代的内容是一致的，如果是 in source 编译，指得就是工程顶层目录，如果
是 out-of-source 编译，指的是工程编译发生的目录。PROJECT_BINARY_DIR 跟其他
指令稍有区别，现在，你可以理解为他们是一致的。
２，CMAKE_SOURCE_DIR
 PROJECT_SOURCE_DIR
 <projectname>_SOURCE_DIR
这三个变量指代的内容是一致的，不论采用何种编译方式，都是工程顶层目录。
也就是在 in source 编译时，他跟 CMAKE_BINARY_DIR 等变量一致。
PROJECT_SOURCE_DIR 跟其他指令稍有区别，现在，你可以理解为他们是一致的。
３，CMAKE_CURRENT_SOURCE_DIR
指的是当前处理的 CMakeLists.txt 所在的路径，比如上面我们提到的 src 子目录。
４，CMAKE_CURRRENT_BINARY_DIR
如果是 in-source 编译，它跟 CMAKE_CURRENT_SOURCE_DIR 一致，如果是 out-ofsource
编译，他指的是 target 编译目录。
使用我们上面提到的 ADD_SUBDIRECTORY(src bin)可以更改这个变量的值。
使用 SET(EXECUTABLE_OUTPUT_PATH <新路径>)并不会对这个变量造成影响，它仅仅
修改了最终目标文件存放的路径。
５，CMAKE_CURRENT_LIST_FILE
输出调用这个变量的 CMakeLists.txt 的完整路径
６，CMAKE_CURRENT_LIST_LINE
输出这个变量所在的行
7，CMAKE_MODULE_PATH
这个变量用来定义自己的 cmake 模块所在的路径。如果你的工程比较复杂，有可能会自己
编写一些 cmake 模块，这些 cmake 模块是随你的工程发布的，为了让 cmake 在处理
CMakeLists.txt 时找到这些模块，你需要通过 SET 指令，将自己的 cmake 模块路径设
置一下。
比如
SET(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)
这时候你就可以通过 INCLUDE 指令来调用自己的模块了。
８，EXECUTABLE_OUTPUT_PATH 和 LIBRARY_OUTPUT_PATH
分别用来重新定义最终结果的存放目录，前面我们已经提到了这两个变量。
9，PROJECT_NAME
返回通过 PROJECT 指令定义的项目名称。

```







