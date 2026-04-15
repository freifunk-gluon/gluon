cmake_minimum_required(VERSION 3.20)

project(libgluonutil C)

set_property(DIRECTORY PROPERTY COMPILE_DEFINITIONS _GNU_SOURCE)

add_library(gluonutil SHARED libgluonutil.c)
set_property(TARGET gluonutil PROPERTY COMPILE_FLAGS "-Wall -std=c99")
target_link_libraries(gluonutil json-c uci)
install(TARGETS gluonutil
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
)

install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/libgluonutil.h DESTINATION include)
