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
    [view release];
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
    [view release];
}
