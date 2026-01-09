cmake_minimum_required(VERSION 3.20)

project(gluon-core C)

add_library(site MODULE site.c)
set_property(TARGET site PROPERTY PREFIX "")
set_property(TARGET site PROPERTY COMPILE_FLAGS "-Wall -std=c99")
target_link_libraries(site gluonutil lua lua-jsonc)

install(TARGETS site
  LIBRARY DESTINATION lib/lua/gluon
)
