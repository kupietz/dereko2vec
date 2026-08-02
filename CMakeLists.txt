cmake_minimum_required(VERSION 3.9)
project(dereko2vec VERSION 0.9.1 DESCRIPTION "Fork from wang2vec with extensions for re-training and count based models")
option(STATIC_DEREKO2VEC "Build dereko2vec as a static binary" OFF)

set(CMAKE_VERBOSE_MAKEFILE on)
if (CMAKE_BUILD_TYPE MATCHES Debug)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g -O0 -Wall -Wextra -Wno-unused-parameter -Wno-unused-variable -Wno-unused-function -Wno-unused-but-set-variable -Wno-unused-but-set-parameter -Wno-unused-value -Wno-unused-result")
else ()
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O3 -march=native -mtune=native -Wall -funroll-loops")
endif ()
set(ADDITIONAL_LIBS ${ADDITIONAL_LIBS} m pthread rt snappy z bz2 lz4 zstd stdc++ dl)
include(GNUInstallDirs)

include_directories(/usr/local/include;/usr/local/kl/include)
link_directories(/usr/local/kl/lib;/usr/local/lib;/usr/local/lib64)

# A static dereko2vec needs everything as a static library. An ordinary build
# takes the shared ones, and it has to take them explicitly: a leftover static
# library below /usr/local would otherwise win over the shared library of the
# distribution, because cmake weighs the search path higher than the suffix.
# Set -DCOLLOCATORDB=<path> or -DROCKSDB=<path> to pick specific ones.
if (STATIC_DEREKO2VEC)
    find_library(COLLOCATORDB libcollocatordb_static.a)
    find_library(ROCKSDB librocksdb.a)
else ()
    set(_dereko2vec_lib_suffixes ${CMAKE_FIND_LIBRARY_SUFFIXES})
    set(CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_SHARED_LIBRARY_SUFFIX})
    find_library(COLLOCATORDB NAMES collocatordb)
    find_library(ROCKSDB NAMES rocksdb)
    set(CMAKE_FIND_LIBRARY_SUFFIXES ${_dereko2vec_lib_suffixes})
endif ()

if (NOT COLLOCATORDB)
    message(FATAL_ERROR "No collocatordb found. Please install it from "
            "https://korap.ids-mannheim.de/gerrit/plugins/gitiles/ids-kl/collocatordb"
            " - a static dereko2vec needs libcollocatordb_static.a, otherwise "
            "libcollocatordb.so is enough.")
endif ()
if (NOT ROCKSDB)
    message(FATAL_ERROR "No rocksdb found. Install the rocksdb development "
            "package of your distribution, e.g. librocksdb-dev or rocksdb-devel.")
endif ()
message(STATUS "Using collocatordb ${COLLOCATORDB}")
message(STATUS "Using RocksDB ${ROCKSDB}")

file(GLOB APP_SOURCES ${CMAKE_SOURCE_DIR}/src/*.c)
foreach (mysourcefile ${APP_SOURCES})
    # I used a simple string replace, to cut off .cpp.
    string(REPLACE ".c" "" myname ${mysourcefile})
    string(REGEX REPLACE ".*/" "" myname ${myname})
    add_executable(${myname} ${mysourcefile})
    # Make sure YourLib is linked to each app
    if (${myname} MATCHES "derek")
        target_link_libraries(${myname} ${COLLOCATORDB} ${ROCKSDB} ${ADDITIONAL_LIBS})
        if(STATIC_DEREKO2VEC)
            set_target_properties(${myname} PROPERTIES LINK_FLAGS "-static")
        endif()
    else ()
        target_link_libraries(${myname} m pthread)
    endif ()
endforeach (mysourcefile ${APP_SOURCES})

# Only the two that are used outside of a build directory: the trainer and the
# converter that writes the memory mappable form derekovecs maps. The remaining
# programs keep the generic names they inherited from word2vec, like distance
# or kmeans_txt, which have no business in a directory on everybody's PATH.
#
# The installed dereko2vec gets the directory of the collocatordb it was linked
# against as its rpath. An installation below /usr/local is not in the search
# path of the loader by default, and without this it only starts with
# LD_LIBRARY_PATH set.
if (NOT STATIC_DEREKO2VEC)
    get_filename_component(COLLOCATORDB_LIBDIR "${COLLOCATORDB}" DIRECTORY)
    list(FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES "${COLLOCATORDB_LIBDIR}" isSystemLibDir)
    if ("${isSystemLibDir}" STREQUAL "-1")
        set_target_properties(dereko2vec PROPERTIES INSTALL_RPATH "${COLLOCATORDB_LIBDIR}")
    endif ()
endif ()
install(TARGETS dereko2vec vecs2mmap RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})

enable_testing()
find_program(BASH_PROGRAM bash)
if (BASH_PROGRAM)
    add_test(type-3-test ${BASH_PROGRAM} ${CMAKE_CURRENT_SOURCE_DIR}/tests/test-type-3.sh)
else ()
    message(SEND_ERROR "Cannot find bash, needed for testing")
endif ()
