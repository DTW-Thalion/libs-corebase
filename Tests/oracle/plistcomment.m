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
  printf ("%-34s len=%5ld -> ", name, (long) len);
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
      char tb[120], db[300];

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

/* Build <prefix> followed by a "//" comment padded with spaces to a total
   of len bytes, with no trailing newline. */
static CFIndex
build (UInt8 *buf, const char *prefix, const char *comment, CFIndex len)
{
  size_t p = strlen (prefix);
  size_t c = strlen (comment);

  memcpy (buf, prefix, p);
  memcpy (buf + p, comment, c);
  memset (buf + p + c, ' ', len - p - c);
  return len;
}

int
main (void)
{
  UInt8 buf[1200];
  CFIndex n;

  show ("short: ( foo", (const UInt8 *) "(foo", 4);
  show ("short: ( foo //c", (const UInt8 *) "(foo //c", 8);
  show ("short: { a = b;", (const UInt8 *) "{a=b;", 5);
  show ("short: { a = b; //c", (const UInt8 *) "{a=b; //c", 9);
  show ("short: { a = b; } trailing //c",
        (const UInt8 *) "{a=b;} //c", 10);
  show ("short: ( foo ) trailing //c", (const UInt8 *) "(foo) //c", 9);
  show ("short: quoted then //c", (const UInt8 *) "\"foo\" //c", 9);

  n = build (buf, "(foo", "//", 1102);
  show ("big: ( foo //<pad>", buf, n);

  n = build (buf, "{a=b;", "//", 1102);
  show ("big: { a = b; //<pad>", buf, n);

  n = build (buf, "(foo", "/*", 1102);
  show ("big: ( foo /*<pad>", buf, n);

  n = build (buf, "(foo,", "//", 1102);
  show ("big: ( foo , //<pad>", buf, n);

  n = build (buf, "{a=b;}", "//", 1102);
  show ("big: { a = b; } //<pad>", buf, n);

  n = build (buf, "(foo)", "//", 1102);
  show ("big: ( foo ) //<pad>", buf, n);

  n = build (buf, "\"foo\"", "//", 1102);
  show ("big: quoted //<pad>", buf, n);

  return 0;
}
