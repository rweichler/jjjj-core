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

        NSString *new = [@"dpkgapp://" stringByAppendingString:path];
        NSLog(@"OH OK THEN %@", new);
        return [NSURL URLWithString:new];
    }
    NSLog(@"deepkg WAU %@\n", url);
    return nil;
}
@end
