#include <fbjni/fbjni.h>
#include "VisionCameraTextScannerOnLoad.hpp"

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM* vm, void*) {
  return facebook::jni::initialize(vm, []() {
    margelo::nitro::camera::textrecognizer::registerAllNatives();
  });
}