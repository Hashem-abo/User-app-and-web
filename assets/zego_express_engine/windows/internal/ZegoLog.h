#pragma once
#include <string>

namespace ZF {
    void logInfo(const char *format, ...);

    std::string getApiTimeExtendedJsonData(const std::string &extended_info, bool only_push = false);
    }
