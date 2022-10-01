macro(setup_git_branch)
    execute_process(
        COMMAND git rev-parse --abbrev-ref HEAD
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
        OUTPUT_VARIABLE GIT_BRANCH
        OUTPUT_STRIP_TRAILING_WHITESPACE)
endmacro()

macro(setup_git_commit_hash)
    execute_process(
        COMMAND git log -1 --format=%h --abbrev=8
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
        OUTPUT_VARIABLE GIT_COMMIT_HASH
        OUTPUT_STRIP_TRAILING_WHITESPACE)
endmacro()

macro(setup_git_commit_count)
    execute_process(
        COMMAND git rev-list --count HEAD
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
        OUTPUT_VARIABLE GIT_COMMIT_COUNT
        OUTPUT_STRIP_TRAILING_WHITESPACE)
endmacro()

macro(setup_git_commit_date)
    execute_process(
        COMMAND bash "-c" "git log -1 --date='format:%Y/%m/%d %H:%M:%S' --format='%cd'"
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
        OUTPUT_VARIABLE GIT_COMMIT_DATE
        OUTPUT_STRIP_TRAILING_WHITESPACE)
endmacro()

macro(setup_git_diff_name_only)
    execute_process(
        COMMAND bash "-c" "git diff --name-only | tr '\n' ','"
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
        OUTPUT_VARIABLE GIT_DIFF_NAME_ONLY
        OUTPUT_STRIP_TRAILING_WHITESPACE)
endmacro()

macro(setup_username_hostname)
    execute_process(
        COMMAND bash "-c" "echo $(id -u -n)@$(hostname) | tr '\n' ' '"
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
        OUTPUT_VARIABLE USERNAME_HOSTNAME
        OUTPUT_STRIP_TRAILING_WHITESPACE)
endmacro()

macro(print_include_directories)
    get_property(
        dirs
        DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        PROPERTY INCLUDE_DIRECTORIES)
    message(STATUS "all include directories:")
    foreach(dir ${dirs})
        message(STATUS "-   ${dir}")
    endforeach()
endmacro()

macro(print_all_linked_libraries target)
    get_target_property(libs ${target} LINK_LIBRARIES)
    message(STATUS "all linked libraries: (against ${target})")
    foreach(lib ${libs})
        message(STATUS "-   ${lib}")
    endforeach()
endmacro()

macro(print_all_variables)
    get_cmake_property(vars VARIABLES)
    list(SORT vars)
    message(STATUS "all variables:")
    foreach(var ${vars})
        message(STATUS "-   ${var}=${${var}}")
    endforeach()
endmacro()

macro(configure_version_h)
    setup_username_hostname()
    setup_git_branch()
    setup_git_commit_hash()
    setup_git_commit_count()
    setup_git_commit_date()
    setup_git_diff_name_only()
    extract_version_from_changelog()
    string(TOUPPER ${PROJECT_NAME} PROJECT_NAME_UPPERCASE)
    set(VERSION_H "${CMAKE_BINARY_DIR}/${PROJECT_NAME}/version.h")
    configure_file(${PACKAGE_UTILS_CMAKE_DIRNAME}/version.h.in ${VERSION_H} @ONLY)
    install(FILES ${VERSION_H} DESTINATION "include/${PROJECT_NAME}")
endmacro()

macro(configure_output_directories)
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin)
endmacro()