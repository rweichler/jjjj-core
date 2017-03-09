#import <Foundation/Foundation.h>
#define ROCKETBOOTSTRAP_LOAD_DYNAMIC
#import <LightMessaging/LightMessaging.h>

bool run_lua_code(const char *code, const char **result);
void unwind_lua_stack();

static void callback( CFMachPortRef port,
                            LMMessage *request,
                            size_t size,
                            void *info)
{
    // get the reply port
    mach_port_t replyPort = request->head.msgh_remote_port;

    // sanity check
    if (!LMDataWithSizeIsValidMessage(request, size)) {
        LMSendReply(replyPort, NULL, 0);
        LMResponseBufferFree((LMResponseBuffer *)request);
        return;
    }

    const char *data = LMMessageGetData(request);

    const char *result;
    bool success = run_lua_code(data, &result);

    if(result == NULL) {
        LMSendReply(replyPort, NULL, 0);
        LMResponseBufferFree((LMResponseBuffer *)request);
        return;
    }
    char bytes[strlen("ERROR: ") + strlen(result) + 1];
    bytes[0] = 0;
    if(!success) {
        strcat(bytes, "ERROR: ");
    }
    strcat(bytes, result);

    unwind_lua_stack();

    LMSendReply(replyPort, bytes, strlen(bytes) + 1);
    LMResponseBufferFree((LMResponseBuffer *)request);
}

void server_start()
{
    LMStartService("com.r333d.lucy.jjjj", CFRunLoopGetCurrent(), (CFMachPortCallBack)callback);
}
