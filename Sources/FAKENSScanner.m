#import "FAKENSScanner.h"
#import <string.h>

@implementation FAKENSScanner
+ (FAKENSScanner*) scannerWithString:(NSString*) str {
  FAKENSScanner* sc = [[FAKENSScanner alloc] initWithString:str];
  return [sc autorelease];
}

- (id) initWithString:(NSString*) str {
  buff = [str cString];

  self = [super init];
  return self;
}

- (void) skipCharacters {
  id aSet = [self charactersToBeSkipped];

  if (!aSet) return;
  if (buff[0] == '\0') return;
  
  //unsigned char bitmap[8192];
  unsigned char* bitmap = (unsigned char*)[[aSet bitmapRepresentation] bytes];

  for (;;) {
    unsigned char n = buff[0];
    if (n == '\0') {
      return;
    }
    else if (bitmap[n >> 3] & (((unsigned int)1) << (n & 7))) {
      buff++;
    }
    else {
      return;
    }
  }
}

- (BOOL) scanUpToCharactersFromSet:(NSCharacterSet*)aSet intoString: (NSString**)value {
  [self skipCharacters];
  //NSLog(@"XXXXXXXXXXXXXXXXXXXXXXXXXXX");
  return NO;
}


- (BOOL) scanCharactersFromSet:(NSCharacterSet*)aSet intoString: (NSString**)value {
  if (buff[0] == '\0') return NO;
  [self skipCharacters];
  
  //unsigned char bitmap[8192];
  unsigned char* bitmap = (unsigned char*)[[aSet bitmapRepresentation] bytes];

  NSInteger x = 0;
  for (;; x++) {
    unsigned char n = buff[x];
    if (n == '\0') {
      break;
    }
    else if (bitmap[n >> 3] & (((unsigned int)1) << (n & 7))) {
    }
    else {
      break;
    }
  }

  if (x > 0) {
    if (value) {
      NSString* str = [[NSString alloc] initWithBytes:buff length:x encoding:NSUTF8StringEncoding];
      *value = [str autorelease];
    }

    buff += x;
    return YES;
  }
  else {
    return NO;
  }
}

- (BOOL) scanString:(NSString*)string intoString:(NSString**)value {
  if (!string) return NO;
  [self skipCharacters];

  //NSLog(@"1XX scanString [%@] [%s]", string, buff);
  char *ch = strstr(buff, [string cString]);
  if (ch == buff) {
    NSInteger len = [string length];
    if (value) {
      NSString* str = [[NSString alloc] initWithBytes:ch length:len encoding:NSUTF8StringEncoding];
      *value = [str autorelease];
    }
    buff += len;
    //NSLog(@"YES %ld", len);
    return YES;
  }
  else {
    //NSLog(@"NO");
    return NO;
  }
}

- (BOOL) scanUpToString:(NSString*)string intoString:(NSString**)value {
  if (!string) return NO;
  [self skipCharacters];

  //NSLog(@"2XX scanUpToString [%@] [%s]", string, buff);
  char *ch = strstr(buff, [string cString]);
  if (ch == buff) {
    //NSLog(@"NO");
    return NO;
  }
  else if (ch) {
    NSInteger len = ch - buff;
    if (value) {
      NSString* str = [[NSString alloc] initWithBytes:buff length:len encoding:NSUTF8StringEncoding];
      *value = [str autorelease];
    }
    buff = ch;
    //NSLog(@"YES %ld", len);
    return YES;
  }
  else {
    NSInteger len = strlen(buff);
    if (value) {
      NSString* str = [[NSString alloc] initWithBytes:buff length:len encoding:NSUTF8StringEncoding];
      *value = [str autorelease];
    }
    buff += len;
    //NSLog(@"YES %ld", len);
    return YES;
  }
}

- (BOOL) scanDouble:(double *)value {
  return NO;
}

- (BOOL) isAtEnd {
  [self skipCharacters];
  if (buff[0] == '\0') {
    //NSLog(@"at the end YES");
    return YES;
  }
  else {
    //NSLog(@"at the end NO");
    return NO;
  }
}

@end
