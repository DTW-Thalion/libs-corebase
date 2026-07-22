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

static Boolean
eq (CFStringRef got, const char *want)
{
  Boolean ok = false;
  if (got != NULL)
    {
      CFStringRef w = CFStringCreateWithCString (NULL, want,
        kCFStringEncodingUTF8);
      ok = CFEqual (got, w);
      CFRelease (w);
    }
  return ok;
}

static Boolean
urleq (CFURLRef u, const char *want)
{
  return u != NULL && eq (CFURLGetString (u), want);
}

int main (void)
{
  CFURLRef u, r;
  CFStringRef s;

  /* extensionless path: is CopyPathExtension "" or NULL? */
  u = mk ("http://host/dir/file");
  s = CFURLCopyPathExtension (u);
  PASS_CF(s != NULL, "CopyPathExtension of an extensionless path is non-NULL.");
  PASS_CF(s != NULL && CFStringGetLength (s) == 0,
    "CopyPathExtension of an extensionless path is empty.");
  if (s) CFRelease (s);

  r = CFURLCreateCopyAppendingPathExtension (NULL, u, CFSTR("txt"));
  PASS_CF(urleq (r, "http://host/dir/file.txt"), "AppendingPathExtension txt.");
  if (r) CFRelease (r);

  r = CFURLCreateCopyAppendingPathComponent (NULL, u, CFSTR("sub"), false);
  PASS_CF(urleq (r, "http://host/dir/file/sub"), "AppendingPathComponent sub.");
  if (r) CFRelease (r);

  r = CFURLCreateCopyAppendingPathComponent (NULL, u, CFSTR("sub"), true);
  PASS_CF(urleq (r, "http://host/dir/file/sub/"),
    "AppendingPathComponent as directory adds a trailing slash.");
  if (r) CFRelease (r);
  CFRelease (u);

  /* trailing slash last component */
  u = mk ("http://host/dir/");
  s = CFURLCopyLastPathComponent (u);
  PASS_CF(eq (s, "dir"), "LastPathComponent with a trailing slash is 'dir'.");
  if (s) CFRelease (s);
  CFRelease (u);

  return 0;
}
