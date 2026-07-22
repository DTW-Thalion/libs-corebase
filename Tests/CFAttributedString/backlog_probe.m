#include <CoreFoundation/CoreFoundation.h>
#include <stdio.h>

static void
dumpPerChar (const char *label, CFAttributedStringRef s)
{
  CFIndex i, len;
  CFStringRef str;
  char buf[128] = {0};
  static const char *keys[] = { "color", "weight", "lang", NULL };

  str = CFAttributedStringGetString (s);
  len = CFStringGetLength (str);
  CFStringGetCString (str, buf, sizeof buf, kCFStringEncodingUTF8);
  printf ("%s: \"%s\" len=%ld\n", label, buf, (long)len);
  for (i = 0; i < len; i++)
    {
      int k;
      printf ("  [%ld]", (long)i);
      for (k = 0; keys[k] != NULL; k++)
        {
          CFStringRef key = CFStringCreateWithCString (NULL, keys[k],
                                                       kCFStringEncodingUTF8);
          CFStringRef v = CFAttributedStringGetAttribute (s, i, key, NULL);
          char vb[64] = {0};
          if (v != NULL)
            {
              CFStringGetCString (v, vb, sizeof vb, kCFStringEncodingUTF8);
              printf (" %s=%s", keys[k], vb);
            }
          CFRelease (key);
        }
      printf ("\n");
    }
}

static CFMutableAttributedStringRef
build (const char *cstr)
{
  CFStringRef s = CFStringCreateWithCString (NULL, cstr, kCFStringEncodingUTF8);
  CFMutableAttributedStringRef m = CFAttributedStringCreateMutable (NULL, 0);
  CFAttributedStringReplaceString (m, CFRangeMake (0, 0), s);
  CFRelease (s);
  return m;
}

static void
setAttr (CFMutableAttributedStringRef m, CFRange r, const char *k, const char *v)
{
  CFStringRef key = CFStringCreateWithCString (NULL, k, kCFStringEncodingUTF8);
  CFStringRef val = CFStringCreateWithCString (NULL, v, kCFStringEncodingUTF8);
  CFAttributedStringSetAttribute (m, r, key, val);
  CFRelease (key);
  CFRelease (val);
}

int
main (void)
{
  CFMutableAttributedStringRef m;
  CFAttributedStringRef sub;
  CFStringRef key;

  /* 1. CreateWithSubstring: "Hello World", (0,5)=color:red, (6,5)=weight:bold.
   * substring (3,5) = "lo Wo".
   */
  m = build ("Hello World");
  setAttr (m, CFRangeMake (0, 5), "color", "red");
  setAttr (m, CFRangeMake (6, 5), "weight", "bold");
  sub = CFAttributedStringCreateWithSubstring (NULL, m, CFRangeMake (3, 5));
  dumpPerChar ("CreateWithSubstring(3,5)", sub);
  CFRelease (sub);
  CFRelease (m);

  /* 2. RemoveAttribute: (0,11)=color, (0,5) also weight; remove color over (0,11). */
  m = build ("Hello World");
  setAttr (m, CFRangeMake (0, 11), "color", "red");
  setAttr (m, CFRangeMake (0, 5), "weight", "bold");
  key = CFSTR ("color");
  CFAttributedStringRemoveAttribute (m, CFRangeMake (0, 11), key);
  dumpPerChar ("after RemoveAttribute(color,0-11)", m);
  CFRelease (m);

  /* 3. ReplaceAttributedString: base "Hello World" color:red all;
   * replace (0,5) with "HI"{weight:bold}. */
  m = build ("Hello World");
  setAttr (m, CFRangeMake (0, 11), "color", "red");
  {
    CFMutableAttributedStringRef repl = build ("HI");
    setAttr (repl, CFRangeMake (0, 2), "weight", "bold");
    CFAttributedStringReplaceAttributedString (m, CFRangeMake (0, 5), repl);
    dumpPerChar ("after ReplaceAttributedString(0-5, HI{weight})", m);
    CFRelease (repl);
  }
  CFRelease (m);

  printf ("PROBE DONE\n");
  return 0;
}
