#include <CoreFoundation/CoreFoundation.h>
#include <stdio.h>

#pragma clang diagnostic ignored "-Wdeprecated-declarations"

static void
dump (const char *label, CFStringRef s)
{
  char buf[512] = {0};
  if (s == NULL)
    {
      printf ("%s: (null)\n", label);
      return;
    }
  CFStringGetCString (s, buf, sizeof buf, kCFStringEncodingUTF8);
  printf ("%s: \"%s\"\n", label, buf);
}

int
main (void)
{
  CFStringRef in;
  CFStringRef esc;
  CFStringRef un;

  /* Each of the five predefined entities plus plain text. */
  in = CFSTR ("a<b>c&d\"e'f");
  esc = CFXMLCreateStringByEscapingEntities (NULL, in, NULL);
  dump ("escape a<b>c&d\"e'f", esc);
  if (esc)
    {
      un = CFXMLCreateStringByUnescapingEntities (NULL, esc, NULL);
      dump ("unescape roundtrip", un);
      if (un) CFRelease (un);
      CFRelease (esc);
    }

  /* A string with no special characters. */
  in = CFSTR ("plain text 123");
  esc = CFXMLCreateStringByEscapingEntities (NULL, in, NULL);
  dump ("escape plain", esc);
  if (esc) CFRelease (esc);

  /* Unescape a numeric character reference and named entities. */
  in = CFSTR ("x &amp; y &lt;z&gt; &#65; &quot;q&quot; &apos;");
  un = CFXMLCreateStringByUnescapingEntities (NULL, in, NULL);
  dump ("unescape mix", un);
  if (un) CFRelease (un);

  /* Empty string. */
  esc = CFXMLCreateStringByEscapingEntities (NULL, CFSTR (""), NULL);
  dump ("escape empty", esc);
  if (esc) CFRelease (esc);

  printf ("PROBE DONE\n");
  return 0;
}
