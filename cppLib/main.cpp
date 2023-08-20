// thread example
#include <iostream> // std::cout
#include <thread>   // std::thread
#include <chrono>
#include <sstream>
#include <mutex>
#include <stdatomic.h>
#include "./chatlib/gpt4all/gpt4all-backend/llmodel_c.h"

// ====================================================

class PrintThread : public std::ostringstream
{
public:
    PrintThread() = default;

    ~PrintThread()
    {
        std::lock_guard<std::mutex> guard(_mutexPrint);
        std::cout << this->str();
    }

private:
    static std::mutex _mutexPrint;
};

std::mutex PrintThread::_mutexPrint{};

// ====================================================

atomic_bool stop = false;

void foo()
{
    PrintThread{} << "in foo \n";

    while (!stop)
    {
        PrintThread{} << "running\n";
    }

    PrintThread{} << "out foo \n";
}

void bar(int x)
{
    PrintThread{} << "in bar\n";

    std::this_thread::sleep_for(std::chrono::milliseconds(1));

    stop = true;

    PrintThread{} << "out bar \n";
}

int main()
{
    std::thread first(foo);     // spawn new thread that calls foo()
    std::thread second(bar, 0); // spawn new thread that calls bar(0)

    llmodel_set_implementation_search_path("/home/steve/.local/share/re.distantfutu.deckr/gpt/libs/");

    PrintThread{} << llmodel_get_implementation_search_path();
    PrintThread{} << "\n";

    PrintThread{} << "main, foo and bar now execute concurrently...\n";

    // synchronize threads:
    first.join();  // pauses until first finishes
    second.join(); // pauses until second finishes

    PrintThread{} << "foo and bar completed.\n";

    return 0;
}

// ====================================================================
// dfc overrides

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

bool dfc_llmodel_isModelLoaded_h(llmodel_model model)
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
    return llmodel_prompt(model, prompt, prompt_callback, response_callback, recalculate_callback, ctx);
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