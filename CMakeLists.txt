cmake_minimum_required(VERSION 3.9)
project(dereko2vec VERSION 0.9.0 DESCRIPTION "Fork from wang2vec with extensions for re-training and count based models")
set(CMAKE_VERBOSE_MAKEFILE on)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -lm -pthread -O3 -march=native -mtune=native -Wall -funroll-loops")
set(ADDITIONAL_LIBS pthread rt snappy z bz2 lz4 zstd stdc++ dl)
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
