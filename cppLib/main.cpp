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

extern "C"
{
    enum
    {
        PromptTypeId = 10,
        ResponseTypeId = 20,
        RecalculateTypeId = 30,
        ShutdownTypeId = 40,
    };

    typedef void (*Dart_Callback)(const char *message, int32_t tokenId, int32_t typeId);

    Dart_Callback dart_callback;
    atomic_bool running = false;
    atomic_int responses = 0;
    std::mutex threadMutex;
    std::mutex fprintMutex;

    void llog(const char *message)
    {
        fprintMutex.lock();
        fprintf(stderr, "llog: %s\n", message);
        fprintMutex.unlock();
    }

    const char *copyString(const char *str)
    {
        intptr_t len = strlen(str) + 1; // Length with \0.
        char *copy = new char[len];
        strncpy(copy, str, len); // strtok modifies arg 1.

        return copy;
    }

    intptr_t InitDartApiDL(void *data)
    {
        // Initialize `dart_api_dl.h`
        return Dart_InitializeApiDL(data);
    }

    void RegisterDartCallback(Dart_Callback callback)
    {
        dart_callback = callback;
    }

    // =======================================================
    // llmodel_prompt callbacks

    bool prompt_function(int32_t token_id)
    {
        if (running)
        {
            dart_callback("prompt_function", token_id, PromptTypeId);
        }

        return running;
    }

    bool response_function(int32_t token_id, const char *response)
    {
        llog("in response_function");
        responses += 1;

        if (running)
        {
            intptr_t len = strlen(response) + 1; // Length with \0.

            if (len > 1)
            {
                const char *copy = copyString(response);
                dart_callback(copy, token_id, ResponseTypeId);

                // std::this_thread::sleep_for(std::chrono::milliseconds(10));

                // delete[] copy;
            }
            else
            {
                llog("empty string? ");
            }
        }

        return running;
    }

    bool recalculate_function(bool is_recalculating)
    {
        if (running)
        {
            dart_callback("recalculate_function", is_recalculating ? 1 : 0, RecalculateTypeId);
        }

        return running;
    }

    void dfc_shutdown_gracefully()
    {
        running = false;
        threadMutex.lock();

        dart_callback("shutdown_gracefully", 0, ShutdownTypeId);
        threadMutex.unlock();
    }

    // ==========================================================
    // thread function

    void promptThread(llmodel_model model, const char *prompt,
                      llmodel_prompt_context *ctx)
    {
        llog("in promptThread");
        responses = 0;

        try
        {
            // this solved a crash, need to copy the ctx and use it for the next
            // query
            llmodel_prompt_context copyCtx = *ctx;

            const char *promptCopy = copyString(prompt);
            llog(promptCopy);

            llmodel_prompt(model, promptCopy, prompt_function, response_function, recalculate_function, &copyCtx);

            // some questions get nothing, send something back
            if (responses == 0)
            {
                dart_callback("Sorry, I can't help with that.", 0, ResponseTypeId);
            }
        }
        catch (const std::exception &e)
        {
            llog("llmodel_prompt bombed"); //  %s", e.what());
        }
        catch (...)
        {
            llog("llmodel_prompt bombed");
        }

        llog("out promptThread");

        // give time before we exit the thread?
        std::this_thread::sleep_for(std::chrono::milliseconds(400));

        threadMutex.unlock();
    }

    void threadedPrompt(llmodel_model model, const char *prompt,
                        llmodel_prompt_context *ctx)
    {
        llog("in threadedPrompt");

        running = false;
        threadMutex.lock();
        running = true;
        llog("in threadedPrompt2");

        std::thread t = std::thread(promptThread, model, prompt, ctx);

        t.detach();

        llog("out threadedPrompt");
    }

    // ===============================================================
    // wrapper functions

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
        // saw it crash here, testing if copying the path helps.
        const char *model_path_copy = copyString(model_path);

        return llmodel_loadModel(model, model_path_copy);
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

} // extern "C"
