cmake_minimum_required(VERSION 3.18.1)

project("VisionCameraTextScanner")

# Load autolinking cmake file
include(${CMAKE_SOURCE_DIR}/../nitrogen/generated/android/VisionCameraTextScanner+autolinking.cmake)

add_library(${androidCxxLibName} SHARED
  src/main/cpp/cpp-adapter.cpp
)

target_link_libraries(${androidCxxLibName}
  android
  log
  jnigraphics
)