#include "CoreFoundation/CFURL.h"
#include "../CFTesting.h"

static CFURLRef
mk (const char *s)
{
  CFStringRef str = CFStringCreateWithCString (NULL, s, kCFStringEncodingUTF8);
  CFURLRef u = CFURLCreateWithString (NULL, str, NULL);
  CFRelease (str);
  return u;
}

int main (void)
{
  CFURLRef u, r;
  CFStringRef s;
  CFRange rr;

  u = mk ("http://host/dir/file.txt");
  s = CFURLCopyLastPathComponent (u);
  PASS_CFEQ(s, CFSTR("file.txt"), "last component of .../file.txt");
  CFRelease (s);
  s = CFURLCopyPathExtension (u);
  PASS_CFEQ(s, CFSTR("txt"), "extension of .../file.txt");
  CFRelease (s);
  r = CFURLCreateCopyDeletingLastPathComponent (NULL, u);
  PASS_CFEQ(CFURLGetString (r), CFSTR("http://host/dir/"),
    "deleting last component of .../file.txt");
  CFRelease (r);
  r = CFURLCreateCopyDeletingPathExtension (NULL, u);
  PASS_CFEQ(CFURLGetString (r), CFSTR("http://host/dir/file"),
    "deleting extension of .../file.txt");
  CFRelease (r);
  rr = CFURLGetByteRangeForComponent (u, kCFURLComponentHost, NULL);
  PASS_CF(rr.location == 7 && rr.length == 4, "byte range of host");
  CFRelease (u);

  u = mk ("http://host/dir/file");
  s = CFURLCopyPathExtension (u);
  PASS_CFEQ(s, CFSTR(""), "extension of extensionless path is empty");
  CFRelease (s);
  r = CFURLCreateCopyAppendingPathExtension (NULL, u, CFSTR("txt"));
  PASS_CFEQ(CFURLGetString (r), CFSTR("http://host/dir/file.txt"),
    "appending extension");
  CFRelease (r);
  r = CFURLCreateCopyAppendingPathComponent (NULL, u, CFSTR("sub"), false);
  PASS_CFEQ(CFURLGetString (r), CFSTR("http://host/dir/file/sub"),
    "appending a path component");
  CFRelease (r);
  CFRelease (u);

  u = mk ("http://host/dir/");
  s = CFURLCopyLastPathComponent (u);
  PASS_CFEQ(s, CFSTR("dir"), "last component with a trailing slash");
  CFRelease (s);
  CFRelease (u);

  return 0;
}
