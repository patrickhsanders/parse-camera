
#import "Constants.h"

@implementation Constants


+(NSString *)uploadBucket
{
    return [[NSString stringWithFormat:@"%@-%@", BUCKET, ACCESS_KEY_ID] lowercaseString];
}

@end

