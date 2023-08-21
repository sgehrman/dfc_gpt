// thread example
#include <iostream>
#include <thread>
#include <chrono>
#include <sstream>

#include <mutex>
#include <string.h>
#include <stdatomic.h>
#include <functional>
#include "./chatlib/gpt4all/gpt4all-backend/llmodel_c.h"
#include "./include/dart_api_dl.h"

void (*callback_fp_)(const char *);
Dart_Port callback_send_port_;

#ifdef __cplusplus
extern "C"
{
#endif

    // Initialize `dart_api_dl.h`
    intptr_t InitDartApiDL(void *data)
    {
        return Dart_InitializeApiDL(data);
    }

    void RegisterMyCallback(Dart_Port send_port,
                            void (*callback)(const char *))
    {
        callback_fp_ = callback;
        callback_send_port_ = send_port;
    }

    void threadedPrompt(llmodel_model model, const char *prompt,
                        llmodel_prompt_context *ctx);

    llmodel_model dfc_llmodel_model_create2(const char *model_path, const char *build_variant, llmodel_error *error)
    {
        return llmodel_model_create2(model_path, build_variant, error);
    }

    void dfc_llmodel_model_destroy(llmodel_model model)
    {
        llmodel_model_destroy(model);
    }

    size_t dfc_llmodel_required_mem(llmodel_model model, const char *model_path)
    {
        return llmodel_required_mem(model, model_path);
    }

    bool dfc_llmodel_loadModel(llmodel_model model, const char *model_path)
    {
        return llmodel_loadModel(model, model_path);
    }

    bool dfc_llmodel_isModelLoaded(llmodel_model model)
    {
        return llmodel_isModelLoaded(model);
    }

    uint64_t dfc_llmodel_get_state_size(llmodel_model model)
    {
        return llmodel_get_state_size(model);
    }

    uint64_t dfc_llmodel_save_state_data(llmodel_model model, uint8_t *dest)
    {
        return llmodel_save_state_data(model, dest);
    }

    uint64_t dfc_llmodel_restore_state_data(llmodel_model model, const uint8_t *src)
    {
        return llmodel_restore_state_data(model, src);
    }

    void dfc_llmodel_prompt(llmodel_model model, const char *prompt,
                            llmodel_prompt_callback prompt_callback,
                            llmodel_response_callback response_callback,
                            llmodel_recalculate_callback recalculate_callback,
                            llmodel_prompt_context *ctx)
    {
        threadedPrompt(model, prompt, ctx);
    }

    float *dfc_llmodel_embedding(llmodel_model model, const char *text, size_t *embedding_size)
    {
        return llmodel_embedding(model, text, embedding_size);
    }

    void dfc_llmodel_free_embedding(float *ptr)
    {
        llmodel_free_embedding(ptr);
    }

    void dfc_llmodel_setThreadCount(llmodel_model model, int32_t n_threads)
    {
        llmodel_setThreadCount(model, n_threads);
    }

    int32_t dfc_llmodel_threadCount(llmodel_model model)
    {
        return llmodel_threadCount(model);
    }

    void dfc_llmodel_set_implementation_search_path(const char *path)
    {
        llmodel_set_implementation_search_path(path);
    }

    const char *dfc_llmodel_get_implementation_search_path()
    {
        return llmodel_get_implementation_search_path();
    }

    // =======================================================

    // globals
    atomic_bool running = true;
    std::mutex threadMutex;

    bool prompt_function(int32_t token_id)
    {
        return running;
    }

    bool response_function(int32_t token_id, const char *response)
    {
        if (running)
        {
            intptr_t len = strlen(response) + 1; // Length with \0.

            if (len > 1)
            {
                intptr_t len = strlen(response) + 1; // Length with \0.
                char *copy = new char[len];
                strncpy(copy, response, len); // strtok modifies arg 1.

                callback_fp_(copy);

                // std::this_thread::sleep_for(std::chrono::milliseconds(10));

                // delete[] copy;
            }
            else
            {
                fprintf(stderr, "empty string? ");
            }
        }

        return running;
    }

    bool recalculate_function(bool is_recalculating)
    {
        return running;
    }

    void promptThread(llmodel_model model, const char *prompt,
                      llmodel_prompt_context *ctx)
    {

        try
        {
            // this solved a crash, need to copy the ctx and use it for the next
            // query
            llmodel_prompt_context copyCtx = *ctx;

            llmodel_prompt(model, prompt, prompt_function, response_function, recalculate_function, &copyCtx);
        }
        catch (const std::exception &e)
        {
            fprintf(stderr, "llmodel_prompt bombed: %s", e.what());
        }
        catch (...)
        {
            fprintf(stderr, "llmodel_prompt bombed");
        }

        threadMutex.unlock();
    }

    void threadedPrompt(llmodel_model model, const char *prompt,
                        llmodel_prompt_context *ctx)
    {

        running = false;
        threadMutex.lock();
        running = true;

        std::thread t = std::thread(promptThread, model, prompt, ctx);

        t.detach();
    }

#ifdef __cplusplus
}
#endif
