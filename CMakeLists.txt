cmake_minimum_required(VERSION 3.9)
project(dereko2vec VERSION 0.9.1 DESCRIPTION "Fork from wang2vec with extensions for re-training and count based models")
set(CMAKE_VERBOSE_MAKEFILE on)
if (CMAKE_BUILD_TYPE MATCHES Debug)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -lm -g -O0 -Wall -Wextra -Wno-unused-parameter -Wno-unused-variable -Wno-unused-function -Wno-unused-but-set-variable -Wno-unused-but-set-parameter -Wno-unused-value -Wno-unused-result")
else ()
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -lm -pthread -O3 -march=native -mtune=native -Wall -funroll-loops")
endif ()

# First, try to find static versions
find_library(ZLIB_STATIC NAMES libz.a)
find_library(BZ2_STATIC NAMES libbz2.a)
find_library(LZ4_STATIC NAMES liblz4.a)
find_library(ZSTD_STATIC NAMES libzstd.a)
find_library(SNAPPY_STATIC NAMES libsnappy.a)

# Set each library, preferring static if found
set(ADDITIONAL_LIBS ${ADDITIONAL_LIBS} pthread rt)

if(ZLIB_STATIC)
    set(ADDITIONAL_LIBS ${ADDITIONAL_LIBS} ${ZLIB_STATIC})
else()
    set(ADDITIONAL_LIBS ${ADDITIONAL_LIBS} z)
endif()

if(BZ2_STATIC)
    set(ADDITIONAL_LIBS ${ADDITIONAL_LIBS} ${BZ2_STATIC})
else()
    set(ADDITIONAL_LIBS ${ADDITIONAL_LIBS} bz2)
endif()

if(LZ4_STATIC)
    set(ADDITIONAL_LIBS ${ADDITIONAL_LIBS} ${LZ4_STATIC})
else()
    set(ADDITIONAL_LIBS ${ADDITIONAL_LIBS} lz4)
endif()

if(ZSTD_STATIC)
    set(ADDITIONAL_LIBS ${ADDITIONAL_LIBS} ${ZSTD_STATIC})
else()
    set(ADDITIONAL_LIBS ${ADDITIONAL_LIBS} zstd)
endif()

if(SNAPPY_STATIC)
    set(ADDITIONAL_LIBS ${ADDITIONAL_LIBS} ${SNAPPY_STATIC})
else()
    set(ADDITIONAL_LIBS ${ADDITIONAL_LIBS} snappy)
endif()

set(ADDITIONAL_LIBS ${ADDITIONAL_LIBS} stdc++ dl)

include(GNUInstallDirs)

include_directories(/usr/local/include;/usr/local/kl/include)
link_directories(/usr/local/kl/lib;/usr/local/lib;/usr/local/lib64)

find_library(COLLOCATORDB libcollocatordb_static.a REQUIRED)
if (NOT COLLOCATORDB)
    message(FATAL_ERROR "No libcollocatordb_static.a found. Please install from https://korap.ids-mannheim.de/gerrit/plugins/gitiles/private/collocatordb")
endif ()

find_library(ROCKSDB librocksdb.a REQUIRED)
if (NOT ROCKSDB)
    message(FATAL_ERROR "No librocksdb.a found. Please install like suggested here https://korap.ids-mannheim.de/gerrit/plugins/gitiles/private/collocatordb#install-rocksdb-and-prerequisites")
endif ()

file(GLOB APP_SOURCES ${CMAKE_SOURCE_DIR}/src/*.c)
foreach (mysourcefile ${APP_SOURCES})
    # I used a simple string replace, to cut off .cpp.
    string(REPLACE ".c" "" myname ${mysourcefile})
    string(REGEX REPLACE ".*/" "" myname ${myname})
    add_executable(${myname} ${mysourcefile})
    # Make sure YourLib is linked to each app
    if (${myname} MATCHES "derek")
        target_link_libraries(${myname} ${COLLOCATORDB} ${ROCKSDB} ${ADDITIONAL_LIBS})
    endif ()
endforeach (mysourcefile ${APP_SOURCES})

enable_testing()
find_program(BASH_PROGRAM bash)
if (BASH_PROGRAM)
    add_test(type-3-test ${BASH_PROGRAM} ${CMAKE_CURRENT_SOURCE_DIR}/tests/test-type-3.sh)
else ()
    message(SEND_ERROR "Cannot find bash, needed for testing")
endif ()
