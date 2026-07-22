#include "CoreFoundation/CFPropertyList.h"
#include "CoreFoundation/CFDictionary.h"
#include "CoreFoundation/CFArray.h"
#include "CoreFoundation/CFNumber.h"
#include "CoreFoundation/CFData.h"
#include "../CFTesting.h"

int main (void)
{
  CFStringRef keys[4];
  CFTypeRef values[4];
  CFDictionaryRef dict;
  CFArrayRef arr;
  CFNumberRef a, b, num;
  const void *items[2];
  int n1 = 1, n2 = 2, n42 = 42;
  CFDataRef data;
  CFPropertyListRef parsed;
  CFPropertyListFormat fmt = 0;
  CFErrorRef err = NULL;

  a = CFNumberCreate (NULL, kCFNumberIntType, &n1);
  b = CFNumberCreate (NULL, kCFNumberIntType, &n2);
  items[0] = a;
  items[1] = b;
  arr = CFArrayCreate (NULL, items, 2, &kCFTypeArrayCallBacks);
  num = CFNumberCreate (NULL, kCFNumberIntType, &n42);

  keys[0] = CFSTR("str");
  keys[1] = CFSTR("num");
  keys[2] = CFSTR("flag");
  keys[3] = CFSTR("arr");
  values[0] = CFSTR("hello");
  values[1] = num;
  values[2] = kCFBooleanTrue;
  values[3] = arr;
  dict = CFDictionaryCreate (NULL, (const void **) keys, (const void **) values,
    4, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);

  data = CFPropertyListCreateData (NULL, dict, kCFPropertyListXMLFormat_v1_0,
    0, &err);
  PASS_CF(data != NULL,
    "CFPropertyListCreateData serialises a property list to XML.");

  parsed = CFPropertyListCreateWithData (NULL, data, kCFPropertyListImmutable,
    &fmt, &err);
  PASS_CF(parsed != NULL,
    "CFPropertyListCreateWithData parses the XML back.");
  PASS_CF(fmt == kCFPropertyListXMLFormat_v1_0,
    "CFPropertyListCreateWithData reports the XML format.");
  PASS_CFEQ(parsed, dict,
    "The parsed property list equals the original.");

  if (parsed != NULL)
    CFRelease (parsed);
  if (data != NULL)
    CFRelease (data);
  if (err != NULL)
    CFRelease (err);
  CFRelease (dict);
  CFRelease (arr);
  CFRelease (num);
  CFRelease (a);
  CFRelease (b);

  return 0;
}
