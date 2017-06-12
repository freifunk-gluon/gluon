cmake_minimum_required(VERSION 2.6)

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR})

project(libgluonutil C)

set(LIBDIR "lib${LIB_SUFFIX}")

find_package(JSON_C REQUIRED)

set_property(DIRECTORY PROPERTY COMPILE_DEFINITIONS _GNU_SOURCE)

add_library(gluonutil SHARED libgluonutil.c)
set_property(TARGET gluonutil PROPERTY COMPILE_FLAGS "-Wall -std=c99 ${JSON_C_CFLAGS_OTHER}")
set_property(TARGET gluonutil PROPERTY LINK_FLAGS "${JSON_C_LDFLAGS_OTHER}")
set_property(TARGET gluonutil APPEND PROPERTY INCLUDE_DIRECTORIES ${JSON_C_INCLUDE_DIR})
target_link_libraries(gluonutil ${JSON_C_LIBRARIES})
install(TARGETS gluonutil
  ARCHIVE DESTINATION ${LIBDIR}
  LIBRARY DESTINATION ${LIBDIR}
)


install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/libgluonutil.h DESTINATION include)
