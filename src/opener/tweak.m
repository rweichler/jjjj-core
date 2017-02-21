#import <Foundation/Foundation.h>
#import <Opener/HBLOHandler.h>

@interface DPKGOpener : HBLOHandler
@end

@implementation DPKGOpener
-(instancetype)init
{
    self = [super init];

    self.name = @"dpkgopener";
    self.identifier = @"dpkgopener";

    return self;
}
-(NSURL *)openURL:(NSURL *)url sender:(NSString *)sender
{
    if([url.pathExtension isEqualToString:@"deb"]) {
        NSString *urlString = url.absoluteString;
        NSRange dividerRange = [urlString rangeOfString:@"://"];
        NSUInteger divide = NSMaxRange(dividerRange);
        NSString *scheme = [urlString substringToIndex:divide];
        NSString *path = [urlString substringFromIndex:divide];

        if(![scheme isEqualToString:@"dpkgapp://"]) {
            NSString *new = [@"dpkgapp://" stringByAppendingString:url.absoluteString];
            return [NSURL URLWithString:new];
        }

    }
    return nil;
}
@end
