// thread example
#include <stdatomic.h>
#include <string.h>

#include <chrono>
#include <functional>
#include <iostream>
#include <mutex>
#include <sstream>
#include <thread>

#include "./chatlib/gpt4all/gpt4all-backend/llmodel_c.h"
#include "./include/dart_api_dl.h"

extern "C" {
enum {
  PromptTypeId = 10,
  ResponseTypeId = 20,
  RecalculateTypeId = 30,
  ShutdownTypeId = 40,
};

typedef void (*Dart_Callback)(const char *message, int32_t tokenId,
                              int32_t typeId);

Dart_Callback dart_callback;
atomic_bool running = false;
atomic_int responses = 0;
std::mutex threadMutex;
std::mutex fprintMutex;

void llog(const char *message) {
  fprintMutex.lock();
  fprintf(stderr, "llog: %s\n", message);
  fprintMutex.unlock();
}

void myterminate() {
  llog("terminate handler called\n");
  //   abort();  // forces abnormal termination
}

const char *copyString(const char *str) {
  intptr_t len = strlen(str) + 1;  // Length with \0.
  char *copy = new char[len];
  strncpy(copy, str, len);  // strtok modifies arg 1.

  return copy;
}

intptr_t InitDartApiDL(void *data) {
  // Initialize `dart_api_dl.h`
  return Dart_InitializeApiDL(data);
}

void RegisterDartCallback(Dart_Callback callback) {
  dart_callback = callback;

  // SNG tseting
  std::set_terminate(myterminate);
}

// =======================================================
// llmodel_prompt callbacks

bool prompt_function(int32_t token_id) {
  if (running) {
    dart_callback("prompt_function", token_id, PromptTypeId);
  }

  return running;
}

bool response_function(int32_t token_id, const char *response) {
  // llog("in response_function");
  responses += 1;

  if (running) {
    intptr_t len = strlen(response) + 1;  // Length with \0.

    if (len > 1) {
      const char *copy = copyString(response);
      dart_callback(copy, token_id, ResponseTypeId);

      // std::this_thread::sleep_for(std::chrono::milliseconds(10));

      // delete[] copy;
    } else {
      llog("empty string? ");
    }
  }

  return running;
}

bool recalculate_function(bool is_recalculating) {
  if (running) {
    dart_callback(
        is_recalculating ? " recalculating... " : " finished recalculating... ",
        0, RecalculateTypeId);
  }

  return running;
}

void dfc_shutdown_gracefully() {
  try {
    running = false;
    threadMutex.lock();

    dart_callback("shutdown_gracefully", 0, ShutdownTypeId);
  } catch (const std::exception &e) {
    llog("catch const std::exception");
  } catch (...) {
    llog("catch...");
  }

  // getting mystery crashes, I'm guessing this dart_callback is still in flight
  // and crashes if this thread dies?
  // give time before we exit the thread?
  std::this_thread::sleep_for(std::chrono::milliseconds(400));

  threadMutex.unlock();
}

// ==========================================================
// thread function

void promptThread(llmodel_model model, const char *prompt,
                  llmodel_prompt_context *ctx) {
  llog("calling llmodel_prompt()");
  responses = 0;

  try {
    llmodel_prompt(model, prompt, prompt_function, response_function,
                   recalculate_function, ctx);

    // some questions get nothing, send something back
    if (responses == 0) {
      dart_callback("Sorry, I can't help with that.", 0, ResponseTypeId);
    }
  } catch (const std::exception &e) {
    llog("llmodel_prompt bombed");  //  %s", e.what());
  } catch (...) {
    llog("llmodel_prompt bombed");
  }

  llog("out llmodel_prompt()");

  // give time before we exit the thread?
  std::this_thread::sleep_for(std::chrono::milliseconds(400));

  threadMutex.unlock();
}

void threadedPrompt(llmodel_model model, const char *prompt,
                    llmodel_prompt_context *ctx) {
  llog("in threadedPrompt");

  running = false;
  threadMutex.lock();
  running = true;
  llog("threadedPrompt got past lock");

  std::thread t = std::thread(promptThread, model, prompt, ctx);

  t.detach();

  llog("out threadedPrompt");
}

// ===============================================================
// wrapper functions

llmodel_model dfc_llmodel_model_create2(const char *model_path,
                                        const char *build_variant,
                                        llmodel_error *error) {
  try {
    return llmodel_model_create2(model_path, build_variant, error);
  } catch (const std::exception &e) {
    llog("catch const std::exception");
  } catch (...) {
    llog("catch...");
  }

  return nullptr;
}

void dfc_llmodel_model_destroy(llmodel_model model) {
  try {
    llmodel_model_destroy(model);
  } catch (const std::exception &e) {
    llog("catch const std::exception");
  } catch (...) {
    llog("catch...");
  }
}

size_t dfc_llmodel_required_mem(llmodel_model model, const char *model_path) {
  try {
    return llmodel_required_mem(model, model_path);
  } catch (const std::exception &e) {
    llog("catch const std::exception");
  } catch (...) {
    llog("catch...");
  }

  return 0;
}

bool dfc_llmodel_loadModel(llmodel_model model, const char *model_path) {
  try {
    // saw it crash here, testing if copying the path helps.
    const char *model_path_copy = copyString(model_path);

    return llmodel_loadModel(model, model_path_copy);
  } catch (const std::exception &e) {
    llog("catch const std::exception");
  } catch (...) {
    llog("catch...");
  }

  return false;
}

bool dfc_llmodel_isModelLoaded(llmodel_model model) {
  try {
    return llmodel_isModelLoaded(model);
  } catch (const std::exception &e) {
    llog("catch const std::exception");
  } catch (...) {
    llog("catch...");
  }

  return false;
}

uint64_t dfc_llmodel_get_state_size(llmodel_model model) {
  try {
    return llmodel_get_state_size(model);
  } catch (const std::exception &e) {
    llog("catch const std::exception");
  } catch (...) {
    llog("catch...");
  }

  return 0;
}

uint64_t dfc_llmodel_save_state_data(llmodel_model model, uint8_t *dest) {
  try {
    return llmodel_save_state_data(model, dest);
  } catch (const std::exception &e) {
    llog("catch const std::exception");
  } catch (...) {
    llog("catch...");
  }

  return 0;
}

uint64_t dfc_llmodel_restore_state_data(llmodel_model model,
                                        const uint8_t *src) {
  try {
    return llmodel_restore_state_data(model, src);
  } catch (const std::exception &e) {
    llog("catch const std::exception");
  } catch (...) {
    llog("catch...");
  }

  return 0;
}

void dfc_llmodel_prompt(llmodel_model model, const char *prompt,
                        llmodel_prompt_context *ctx) {
  try {
    const char *promptCopy = copyString(prompt);
    llog(promptCopy);

    threadedPrompt(model, promptCopy, ctx);
  } catch (const std::exception &e) {
    llog("catch const std::exception");
  } catch (...) {
    llog("catch...");
  }
}

float *dfc_llmodel_embedding(llmodel_model model, const char *text,
                             size_t *embedding_size) {
  try {
    return llmodel_embedding(model, text, embedding_size);
  } catch (const std::exception &e) {
    llog("catch const std::exception");
  } catch (...) {
    llog("catch...");
  }

  return nullptr;
}

void dfc_llmodel_free_embedding(float *ptr) {
  try {
    llmodel_free_embedding(ptr);
  } catch (const std::exception &e) {
    llog("catch const std::exception");
  } catch (...) {
    llog("catch...");
  }
}

void dfc_llmodel_setThreadCount(llmodel_model model, int32_t n_threads) {
  try {
    llmodel_setThreadCount(model, n_threads);
  } catch (const std::exception &e) {
    llog("catch const std::exception");
  } catch (...) {
    llog("catch...");
  }
}

int32_t dfc_llmodel_threadCount(llmodel_model model) {
  try {
    return llmodel_threadCount(model);
  } catch (const std::exception &e) {
    llog("catch const std::exception");
  } catch (...) {
    llog("catch...");
  }

  return 0;
}

void dfc_llmodel_set_implementation_search_path(const char *path) {
  try {
    llmodel_set_implementation_search_path(path);
  } catch (const std::exception &e) {
    llog("catch const std::exception");
  } catch (...) {
    llog("catch...");
  }
}

const char *dfc_llmodel_get_implementation_search_path() {
  try {
    return llmodel_get_implementation_search_path();
  } catch (const std::exception &e) {
    llog("catch const std::exception");
  } catch (...) {
    llog("catch...");
  }

  return nullptr;
}

}  // extern "C"
