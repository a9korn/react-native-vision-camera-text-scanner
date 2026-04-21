cmake_minimum_required(VERSION 3.18.1)

project("VisionCameraTextScanner")

# Load autolinking cmake file
include(${CMAKE_SOURCE_DIR}/../nitrogen/generated/android/VisionCameraTextScanner+autolinking.cmake)

add_library(${androidCxxLibName} SHARED
  # ... add your CMake sources here
  cpp-adapter.cpp
)

target_link_libraries(${androidCxxLibName}
  # ... link your libraries here
  android
  log
  jnigraphics
)

# Apply prefab dependencies
apply_from_variant("${CMAKE_SOURCE_DIR}/fix-prefab.gradle")