// thread example
#include <stdatomic.h>
#include <string.h>

#include <chrono>
#include <iostream>
#include <mutex>
#include <sstream>
#include <string>
#include <thread>

#include "../gpt4all/gpt4all-backend/llmodel_c.h"
#include "./include/dart_api_dl.h"

extern "C" {
enum {
  PromptTypeId = 10,
  ResponseTypeId = 20,
  RecalculateTypeId = 30,
  ShutdownTypeId = 40,
  PromptDoneTypeId = 50,
};

typedef void (*Dart_Callback)(const char *message, int32_t param,
                              int32_t typeId);

Dart_Callback dart_callback;
atomic_bool running = false;
atomic_int responses = 0;
std::mutex threadMutex;
std::mutex fprintMutex;

// std::this_thread::sleep_for(std::chrono::milliseconds(10));

void llog(const char *message) {
  const std::lock_guard<std::mutex> lock(fprintMutex);

  std::thread::id this_id = std::this_thread::get_id();

  std::ostringstream oss;
  oss << std::this_thread::get_id();

  fprintf(stderr, "(%s) llog: %s\n", oss.str().c_str(), message);
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

void RegisterDartCallback(Dart_Callback callback) { dart_callback = callback; }

// =======================================================
// llmodel_prompt callbacks

bool prompt_function(int32_t token_id) {
  if (running) {
    dart_callback("prompt_function", token_id, PromptTypeId);
  }

  return running;
}

bool response_function(int32_t token_id, const char *response) {
  if (running) {
    intptr_t len = strlen(response);

    if (len > 0) {
      responses += 1;

      // not sure if necessary, remove later
      const char *copy = copyString(response);
      dart_callback(copy, token_id, ResponseTypeId);
    } else {
      llog("response_function: empty string");
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
  running = false;
  threadMutex.lock();

  dart_callback("shutdown_gracefully", 0, ShutdownTypeId);

  threadMutex.unlock();
}

// ==========================================================
// thread function

void prompt_thread(llmodel_model model, const char *prompt,
                   llmodel_prompt_context *ctx) {
  responses = 0;

  llmodel_prompt(model, prompt, prompt_function, response_function,
                 recalculate_function, ctx);

  // some questions get nothing, send something back
  if (responses == 0) {
    dart_callback("Sorry, I can't help with that.", 0, ResponseTypeId);
  }

  dart_callback("prompt_done", responses, PromptDoneTypeId);

  threadMutex.unlock();
}

void threadedPrompt(llmodel_model model, const char *prompt,
                    llmodel_prompt_context *ctx) {
  running = false;
  threadMutex.lock();
  running = true;

  std::thread t = std::thread(prompt_thread, model, prompt, ctx);

  t.detach();
}

// ===============================================================
// wrapper functions

llmodel_model dfc_llmodel_model_create2(const char *model_path,
                                        const char *build_variant,
                                        const char **error) {
  return llmodel_model_create2(model_path, build_variant, error);
}

void dfc_llmodel_model_destroy(llmodel_model model) {
  llmodel_model_destroy(model);
}

size_t dfc_llmodel_required_mem(llmodel_model model, const char *model_path) {
  return llmodel_required_mem(model, model_path);
}

bool dfc_llmodel_loadModel(llmodel_model model, const char *model_path) {
  // not sure if necessary, remove later
  const char *model_path_copy = copyString(model_path);

  return llmodel_loadModel(model, model_path_copy);
}

bool dfc_llmodel_isModelLoaded(llmodel_model model) {
  return llmodel_isModelLoaded(model);
}

uint64_t dfc_llmodel_get_state_size(llmodel_model model) {
  return llmodel_get_state_size(model);
}

uint64_t dfc_llmodel_save_state_data(llmodel_model model, uint8_t *dest) {
  return llmodel_save_state_data(model, dest);
}

uint64_t dfc_llmodel_restore_state_data(llmodel_model model,
                                        const uint8_t *src) {
  return llmodel_restore_state_data(model, src);
}

void dfc_llmodel_prompt(llmodel_model model, const char *prompt,
                        llmodel_prompt_context *ctx) {
  // not sure if necessary, remove later
  const char *promptCopy = copyString(prompt);

  threadedPrompt(model, promptCopy, ctx);
}

float *dfc_llmodel_embedding(llmodel_model model, const char *text,
                             size_t *embedding_size) {
  return llmodel_embedding(model, text, embedding_size);
}

void dfc_llmodel_free_embedding(float *ptr) { llmodel_free_embedding(ptr); }

void dfc_llmodel_setThreadCount(llmodel_model model, int32_t n_threads) {
  llmodel_setThreadCount(model, n_threads);
}

int32_t dfc_llmodel_threadCount(llmodel_model model) {
  return llmodel_threadCount(model);
}

void dfc_llmodel_set_implementation_search_path(const char *path) {
  llmodel_set_implementation_search_path(path);
}

const char *dfc_llmodel_get_implementation_search_path() {
  return llmodel_get_implementation_search_path();
}

}  // extern "C"
