// thread example
#include <iostream> // std::cout
#include <thread>   // std::thread
#include "gptlib.h"

void foo()
{
    // do stuff...
}

void bar(int x)
{
    // do stuff...
}

int main()
{
    std::thread first(foo);     // spawn new thread that calls foo()
    std::thread second(bar, 0); // spawn new thread that calls bar(0)

    llmodel_set_implementation_search_path("/home/steve/.local/share/re.distantfutu.deckr/gpt/libs/");

    std::cout << llmodel_get_implementation_search_path();
    std::cout << "\n";

    std::cout << "main, foo and bar now execute concurrently...\n";

    // synchronize threads:
    first.join();  // pauses until first finishes
    second.join(); // pauses until second finishes

    std::cout << "foo and bar completed.\n";

    return 0;
}
