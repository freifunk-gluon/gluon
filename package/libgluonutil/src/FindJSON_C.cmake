# Defines the following variables:
#  JSON_C_FOUND
#  JSON_C_INCLUDE_DIR
#  JSON_C_LIBRARIES
#  JSON_C_CFLAGS_OTHER
#  JSON_C_LDFLAGS_OTHER


find_package(PkgConfig REQUIRED QUIET)

pkg_check_modules(_JSON_C json-c)

find_path(JSON_C_INCLUDE_DIR NAMES json-c/json.h HINTS ${_JSON_C_INCLUDE_DIRS})
find_library(JSON_C_LIBRARIES NAMES json-c HINTS ${_JSON_C_LIBRARY_DIRS})

set(JSON_C_CFLAGS_OTHER "${_JSON_C_CFLAGS_OTHER}" CACHE STRING "Additional compiler flags for json-c")
set(JSON_C_LDFLAGS_OTHER "${_JSON_C_LDFLAGS_OTHER}" CACHE STRING "Additional linker flags for json-c")

find_package_handle_standard_args(JSON_C REQUIRED_VARS JSON_C_LIBRARIES JSON_C_INCLUDE_DIR)
mark_as_advanced(JSON_C_INCLUDE_DIR JSON_C_LIBRARIES JSON_C_CFLAGS_OTHER JSON_C_LDFLAGS_OTHER)
