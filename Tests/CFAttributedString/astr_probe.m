#include <CoreFoundation/CFAttributedString.h>
#include <CoreFoundation/CFString.h>
#include <CoreFoundation/CFDictionary.h>
#include <stdio.h>

static void
prange (const char *l, CFRange r)
{
  printf ("%s=(%ld,%ld)\n", l, (long)r.location, (long)r.length);
}

static void
pstr (const char *l, CFStringRef s)
{
  char b[128] = {0};
  if (s)
    CFStringGetCString (s, b, sizeof b, kCFStringEncodingUTF8);
  printf ("%s='%s'\n", l, s ? b : "(null)");
}

static CFDictionaryRef
oneAttr (CFStringRef k, CFStringRef v)
{
  const void *kk = k;
  const void *vv = v;
  return CFDictionaryCreate (NULL, &kk, &vv, 1,
                             &kCFTypeDictionaryKeyCallBacks,
                             &kCFTypeDictionaryValueCallBacks);
}

int
main (void)
{
  CFRange er;
  CFRange lr;
  CFTypeRef v;
  CFDictionaryRef d;

  CFMutableAttributedStringRef m = CFAttributedStringCreateMutable (NULL, 0);
  CFAttributedStringReplaceString (m, CFRangeMake (0, 0), CFSTR ("Hello World"));
  printf ("len=%ld\n", (long)CFAttributedStringGetLength (m));
  pstr ("string", CFAttributedStringGetString (m));

  CFAttributedStringSetAttribute (m, CFRangeMake (0, 5), CFSTR ("color"),
                                  CFSTR ("red"));
  CFAttributedStringSetAttribute (m, CFRangeMake (0, 11), CFSTR ("font"),
                                  CFSTR ("bold"));

  v = CFAttributedStringGetAttribute (m, 2, CFSTR ("color"), &er);
  pstr ("color@2", v); prange ("  eff", er);
  v = CFAttributedStringGetAttribute (m, 8, CFSTR ("color"), &er);
  pstr ("color@8", v); prange ("  eff", er);
  v = CFAttributedStringGetAttribute (m, 8, CFSTR ("font"), &er);
  pstr ("font@8", v); prange ("  eff", er);

  d = CFAttributedStringGetAttributes (m, 2, &er);
  printf ("attrs@2 count=%ld\n", d ? (long)CFDictionaryGetCount (d) : -1);
  prange ("  eff", er);
  d = CFAttributedStringGetAttributes (m, 8, &er);
  printf ("attrs@8 count=%ld\n", d ? (long)CFDictionaryGetCount (d) : -1);
  prange ("  eff", er);

  v = CFAttributedStringGetAttributeAndLongestEffectiveRange (
        m, 2, CFSTR ("font"), CFRangeMake (0, 11), &lr);
  pstr ("longest font@2", v); prange ("  long", lr);
  v = CFAttributedStringGetAttributeAndLongestEffectiveRange (
        m, 2, CFSTR ("color"), CFRangeMake (0, 11), &lr);
  pstr ("longest color@2", v); prange ("  long", lr);

  d = CFAttributedStringGetAttributesAndLongestEffectiveRange (
        m, 8, CFRangeMake (0, 11), &lr);
  printf ("attrsLongest@8 count=%ld\n", d ? (long)CFDictionaryGetCount (d) : -1);
  prange ("  long", lr);

  CFAttributedStringRemoveAttribute (m, CFRangeMake (0, 11), CFSTR ("color"));
  v = CFAttributedStringGetAttribute (m, 2, CFSTR ("color"), NULL);
  pstr ("color@2 after remove", v);
  d = CFAttributedStringGetAttributes (m, 2, &er);
  printf ("attrs@2 after remove count=%ld\n", d ? (long)CFDictionaryGetCount (d) : -1);
  prange ("  eff", er);

  CFMutableStringRef ms = CFAttributedStringGetMutableString (m);
  printf ("mutableString NULL? %d\n", ms == NULL);
  if (ms)
    pstr ("  ms", ms);

  CFDictionaryRef a = oneAttr (CFSTR ("k"), CFSTR ("v"));
  CFAttributedStringRef ins = CFAttributedStringCreate (NULL, CFSTR ("HI"), a);
  CFAttributedStringReplaceAttributedString (m, CFRangeMake (0, 5), ins);
  pstr ("string after replaceAttrStr", CFAttributedStringGetString (m));
  d = CFAttributedStringGetAttributes (m, 0, &er);
  printf ("attrs@0 after replaceAttrStr count=%ld hasK=%d\n",
          d ? (long)CFDictionaryGetCount (d) : -1,
          (d && CFDictionaryGetValue (d, CFSTR ("k"))) ? 1 : 0);
  prange ("  eff", er);

  CFMutableAttributedStringRef m2 = CFAttributedStringCreateMutable (NULL, 0);
  CFAttributedStringReplaceString (m2, CFRangeMake (0, 0), CFSTR ("abc"));
  CFAttributedStringSetAttribute (m2, CFRangeMake (0, 3), CFSTR ("x"),
                                  CFSTR ("1"));
  CFDictionaryRef repl = oneAttr (CFSTR ("y"), CFSTR ("2"));
  CFAttributedStringSetAttributes (m2, CFRangeMake (0, 3), repl, true);
  d = CFAttributedStringGetAttributes (m2, 1, &er);
  printf ("m2 setAttrs clear=true: count=%ld hasX=%d hasY=%d\n",
          d ? (long)CFDictionaryGetCount (d) : -1,
          (d && CFDictionaryGetValue (d, CFSTR ("x"))) ? 1 : 0,
          (d && CFDictionaryGetValue (d, CFSTR ("y"))) ? 1 : 0);

  printf ("PROBE DONE\n");
  return 0;
}
