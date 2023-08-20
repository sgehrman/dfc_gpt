// thread example
#include <iostream> // std::cout
#include <thread>   // std::thread
#include <chrono>
#include <sstream>
#include <mutex>
#include "gptlib.h"

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

bool stop = false;

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

    std::this_thread::sleep_for(std::chrono::milliseconds(1424));

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
