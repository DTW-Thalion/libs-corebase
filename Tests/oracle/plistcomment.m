#include <CoreFoundation/CoreFoundation.h>
#include <stdio.h>
#include <string.h>

static void
show (const char *name, const UInt8 *bytes, CFIndex len)
{
  CFDataRef data;
  CFPropertyListRef plist;
  CFErrorRef err = NULL;

  data = CFDataCreate (NULL, bytes, len);
  plist = CFPropertyListCreateWithData (NULL, data, kCFPropertyListImmutable,
                                        NULL, &err);
  printf ("%-26s len=%5ld -> ", name, (long) len);
  if (plist == NULL)
    {
      printf ("NULL");
      if (err != NULL)
        {
          CFStringRef d = CFErrorCopyDescription (err);
          char buf[400];

          if (d != NULL
              && CFStringGetCString (d, buf, sizeof buf,
                                     kCFStringEncodingUTF8))
            printf ("   err: %s", buf);
          if (d != NULL)
            CFRelease (d);
        }
      printf ("\n");
    }
  else
    {
      CFStringRef type = CFCopyTypeIDDescription (CFGetTypeID (plist));
      CFStringRef desc = CFCopyDescription (plist);
      char tb[120], db[400];

      if (!CFStringGetCString (type, tb, sizeof tb, kCFStringEncodingUTF8))
        strcpy (tb, "?");
      if (!CFStringGetCString (desc, db, sizeof db, kCFStringEncodingUTF8))
        strcpy (db, "?");
      printf ("%s  desc=<%s>", tb, db);
      if (CFGetTypeID (plist) == CFStringGetTypeID ())
        printf ("  length=%ld", (long) CFStringGetLength (plist));
      printf ("\n");
      CFRelease (type);
      CFRelease (desc);
      CFRelease (plist);
    }
  if (err != NULL)
    CFRelease (err);
  CFRelease (data);
}

int
main (void)
{
  UInt8 buf[1200];

  show ("empty", (const UInt8 *) "", 0);
  show ("space only", (const UInt8 *) " ", 1);
  show ("// short no newline", (const UInt8 *) "// x", 4);
  show ("// short with newline", (const UInt8 *) "// x\n", 5);
  show ("/* */ only", (const UInt8 *) "/* x */", 7);
  show ("/* unterminated", (const UInt8 *) "/* x", 4);
  show ("// then value", (const UInt8 *) "// x\nfoo", 8);
  show ("bare word", (const UInt8 *) "foo", 3);
  show ("quoted string", (const UInt8 *) "\"foo\"", 5);
  show ("empty dict", (const UInt8 *) "{}", 2);

  memset (buf, 'a', 1100);
  show ("1100 bare chars", buf, 1100);

  buf[0] = '/';
  buf[1] = '/';
  memset (buf + 2, ' ', 1100);
  show ("// + 1100 spaces", buf, 1102);

  buf[0] = '/';
  buf[1] = '/';
  memset (buf + 2, 'a', 1100);
  show ("// + 1100 chars", buf, 1102);

  return 0;
}
