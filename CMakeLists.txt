cmake_minimum_required(VERSION 3.5)
project(intersections2d)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMAKE_CXX_STANDARD 14)

set(VERSION_MAJOR 0)
set(VERSION_MINOR 0)
set(VERSION_PATCH 1)

if(NOT CMAKE_BUILD_TYPE OR CMAKE_BUILD_TYPE STREQUAL "")
    set(CMAKE_BUILD_TYPE
        "Release"
        CACHE STRING "" FORCE)
    message(STATUS "Set build type to default: ${CMAKE_BUILD_TYPE}")
else()
    message(STATUS "Your build type: ${CMAKE_BUILD_TYPE}")
endif()
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O0 -ggdb")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O0 -ggdb")
elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O3")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3")
endif()

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -pthread")

set(PYBIND11_CPP_STANDARD -std=c++14)
add_subdirectory(3rdparties/pybind11 ${CMAKE_CURRENT_BINARY_DIR}/pybind11)

include_directories(
    BEFORE
    ${PROJECT_BINARY_DIR}
    ${PROJECT_SOURCE_DIR}/3rdparties/dbg
    ${PROJECT_SOURCE_DIR}/3rdparties/doctest/doctest
    ${PROJECT_SOURCE_DIR}/3rdparties/eigen
    ${PROJECT_SOURCE_DIR}/3rdparties/optional/include
    ${PROJECT_SOURCE_DIR}/src
    ${PROJECT_SOURCE_DIR}/src/intersections2d
    ${PYBIND11_INCLUDE_DIR}
)

option(BUILD_TESTS "Build tests." ON)
if(BUILD_TESTS)
    file(GLOB SRCS tests/test_*.cpp)
    foreach(src ${SRCS})
        string(
            REGEX
            REPLACE "(^.*/|.cpp$)"
                    ""
                    exe
                    ${src})
        add_executable(${exe} ${src})
        install(TARGETS ${exe} RUNTIME DESTINATION bin)
    endforeach(src)
endif()

add_definitions(-DPYBIND11_PROJECT_NAME=${PROJECT_NAME})
pybind11_add_module(${PROJECT_NAME} pybind.cpp)
set_target_properties(${PROJECT_NAME} PROPERTIES BUILD_WITH_INSTALL_RPATH TRUE)
set_target_properties(${PROJECT_NAME} PROPERTIES SKIP_BUILD_RPATH FALSE)
set_target_properties(${PROJECT_NAME} PROPERTIES INSTALL_RPATH_USE_LINK_PATH TRUE)
if(UNIX AND NOT APPLE)
    set_target_properties(${PROJECT_NAME} PROPERTIES INSTALL_RPATH "$ORIGIN")
elseif(APPLE)
    set_target_properties(${PROJECT_NAME} PROPERTIES INSTALL_RPATH "@loader_path")
endif()

include(utils.cmake)
setup_username_hostname()
setup_git_branch()
setup_git_commit_hash()
setup_git_commit_count()
setup_git_commit_date()
setup_git_diff_name_only()

set(PROJECT_REPO_URL "TODO")
set(PROJECT_HOME_URL ${PROJECT_REPO_URL})
set(PROJECT_DOC_URL ${PROJECT_REPO_URL})
set(VERSION_FULL "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}")
set(PROJECT_AUTHOR district10)
set(PROJECT_AUTHOR_EMAIL dvorak4tzx@gmail.com)

# ~~~
# install python package
# ~~~
# install <package>/*cpython*.so
install(
    TARGETS ${PROJECT_NAME}
    LIBRARY DESTINATION python/${PROJECT_NAME}
    ARCHIVE DESTINATION python/${PROJECT_NAME})
# install <package>/__init__.py
set(INIT_PY "${PROJECT_BINARY_DIR}/__init__.py")
configure_file(python/__init__.py ${INIT_PY} @ONLY)
install(FILES ${INIT_PY} DESTINATION python/${PROJECT_NAME})
# install setup.py
set(SETUP_PY "${PROJECT_BINARY_DIR}/setup.py")
configure_file(python/setup.py ${SETUP_PY} @ONLY)
install(FILES ${SETUP_PY} DESTINATION python)
# install Makefile
install(FILES python/Makefile DESTINATION python)
