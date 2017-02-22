#import <UIKit/UIKit.h>
#import "alert.h"

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
    view->_callback = Block_copy(callback);
    [view show];
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
    view->_callback = Block_copy(callback);
    [view show];
}

static dispatch_queue_t queue = NULL;
void pipeit(const char *cmd, void (*callback)(const char *, int))
{
    if(queue == NULL) {
        queue = dispatch_queue_create("OISDJFDSOI", NULL);
    }
    dispatch_queue_t oldQueue = dispatch_get_current_queue();
    dispatch_async(queue, ^{

        FILE *fp;
        char path[1035];

        /* Open the command for reading. */
        fp = popen(cmd, "r");
        if (fp == NULL) {
            printf("Failed to run command\n" );
            exit(1);
        }

        /* Read the output a line at a time - output it. */
        while (fgets(path, sizeof(path)-1, fp) != NULL) {
            char *tmp = malloc(strlen(path) + 1);
            strcpy(tmp, path);
            dispatch_async(oldQueue, ^{
                callback(tmp, 0);
                free(tmp);
            });
        }
        /* close */
        int status = pclose(fp) / 256;
        callback(NULL, status);

    });
}
