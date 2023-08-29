https://github.com/nomic-ai/gpt4all

https://raw.githubusercontent.com/nomic-ai/gpt4all/main/gpt4all-chat/metadata/models.json

https://gpt4all.io/models/models.json

https://github.com/nomic-ai/gpt4all/pull/1023

[Secret Unfiltered Checkpoint](https://the-eye.eu/public/AI/models/nomic-ai/gpt4all/gpt4all-lora-unfiltered-quantized.bin)

- [[Torrent]](https://the-eye.eu/public/AI/models/nomic-ai/gpt4all/gpt4all-lora-unfiltered-quantized.bin.torrent)

https://github.com/nomic-ai/gpt4all/pull/1023

=====================================================================

package up .so files. download from website? macos signing?

handle download errors.

toast when dialog is closed

orca mini what is your specialty?

multiple windows, multiple chats? multiple tabs?
what if we sent the data directly to the app with https? need tabId?

https://riptutorial.com/cmake

https://github.com/dart-lang/samples/blob/main/ffi/primitives/primitives_library/CMakeLists.txt

1.  makefile

https://en.cppreference.com/w/cpp/thread/lock_guard

https://github.com/dart-lang/sdk/issues/37022

// put windows dlls in same folder /gpt?
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
set(BUILD_SHARED_LIBS ON)

// =============================================

$ ldd standalone_test

$ readelf -d ./libllmodel.so.0

$ chrpath -l ./libllmodel.so.0

$ nm libmainlib.dylib | grep Func

objdump -x executable_or_lib.so|grep RPATH

LD_DEBUG=libs ldd ./libdfc-gpt.so
