#include <stdarg.h>
#include <stdio.h>
#include <string>
#include "ZegoLog.h"
#include <ZegoInternalPrivate.h>

#undef __MODULE__
#define __MODULE__ "Flutter"

void ZF::logInfo(const char* format, ...) {
    char log_buf[4096] = { 0 };
    va_list la;
    va_start(la, format);
    int result = vsprintf(log_buf, format, la);
    va_end(la);

    if (result >= 4096) {
        log_buf[4092] = '.';
        log_buf[4093] = '.';
        log_buf[4094] = '.';
        log_buf[4095] = '\0';
    }

    // printf("flutter: %s\n", log_buf);

    zego_express_custom_log(log_buf, __MODULE__);
}

std::string ZF::getApiTimeExtendedJsonData(const std::string &extended_info, bool only_push) {
    char sz[1024] = {0};
    zego_express_get_api_cost_extended_json_data(extended_info.c_str(), only_push, sz, 1024);

    std::string szStr = sz;
    return szStr;
}