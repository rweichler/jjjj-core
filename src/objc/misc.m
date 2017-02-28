#import <UIKit/UIKit.h>

static dispatch_queue_t _queue = NULL;
static dispatch_queue_t queue()
{
    if(_queue == NULL) {
        _queue = dispatch_queue_create("OISDJFDSOI", NULL);
    }
    return _queue;
}

// TODO: figure out a better interface for this
void pipeit(const char *cmd, void (*callback)(const char *, int))
{
    dispatch_async(queue(), ^{

        FILE *fp;
        char path[1035];

        static const char *suffix = " 2>&1";
        char realcmd[strlen(cmd) + strlen(suffix) + 1];
        strcpy(realcmd, cmd);
        strcat(realcmd, suffix);
        fp = popen(realcmd, "r");
        if (fp == NULL) {
            printf("Failed to run command\n" );
            exit(1);
        }

        while (fgets(path, sizeof(path)-1, fp) != NULL) {
            char *tmp = malloc(strlen(path) + 1);
            strcpy(tmp, path);
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(tmp, 0);
                free(tmp);
            });
        }

        int status = pclose(fp) / 256;
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(NULL, status);
        });
    });
}

void run_async(void (*callback)())
{
    dispatch_async(queue(), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            callback();
        });
    });
}

// TODO: fix static method calls in objc.lua so this becomes unnecessary (hard)
void animateit(float duration, float delay, int options, void (*animations)(), void (*completion)(bool))
{
    [UIView animateWithDuration:duration
                          delay:delay
                        options:options
                     animations:^{
                         animations();
                     }
                     completion:^(BOOL finished){
                         completion(finished);
                     }
    ];
}

// TODO: convert these alert functions to Lua (easy, look at ui/table.lua)
typedef void (*alert_callback_t)();
typedef void (*alert_input_callback_t)(const char *response);
void alert_display(const char *title, const char *msg, const char *cancel, const char *ok, alert_callback_t callback);
void alert_input(const char *title, const char *msg, const char *cancel, const char *ok, alert_input_callback_t callback);

@interface EQEAlertView: UIAlertView<UIAlertViewDelegate>
{
@public
    void *_callback;
}
@end
@implementation EQEAlertView
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.cancelButtonIndex != buttonIndex && _callback) {
        if(alertView.alertViewStyle == UIAlertViewStylePlainTextInput) {
            alert_input_callback_t callback = _callback;
            callback([alertView textFieldAtIndex:0].text.UTF8String);
        } else {
            alert_callback_t callback = _callback;
            callback();
        }
        _callback = nil;
    }
    [alertView release];
}
@end

#define NS(x) [NSString stringWithUTF8String:x]

void alert_display(const char *title, const char *msg, const char *cancel, const char *ok, alert_callback_t callback)
{
    EQEAlertView *view;
    if(ok != NULL) {
        view = [EQEAlertView.alloc
                    initWithTitle:NS(title)
                    message:NS(msg)
                    delegate:nil
                    cancelButtonTitle:NS(cancel)
                    otherButtonTitles:NS(ok), nil
                ];
    } else {
        view = [EQEAlertView.alloc
                    initWithTitle:NS(title)
                    message:NS(msg)
                    delegate:nil
                    cancelButtonTitle:NS(cancel)
                    otherButtonTitles:nil
                ];
    }
    view.delegate = view;
    view->_callback = callback;
    dispatch_async(dispatch_get_main_queue(), ^{
        [view show];
    });
}

void alert_input(const char *title, const char *msg, const char *cancel, const char *ok, alert_input_callback_t callback)
{
    EQEAlertView *view = [EQEAlertView.alloc
                            initWithTitle:NS(title)
                            message:NS(msg)
                            delegate:nil
                            cancelButtonTitle:NS(cancel)
                            otherButtonTitles:NS(ok), nil
                          ];
    view.alertViewStyle = UIAlertViewStylePlainTextInput;
    view.delegate = view;
    view->_callback = callback;
    [view show];
}
