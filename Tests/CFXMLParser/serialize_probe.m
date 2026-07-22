#include <CoreFoundation/CoreFoundation.h>
#include <CoreFoundation/CFXMLNode.h>
#include <CoreFoundation/CFXMLParser.h>
#include <stdio.h>

#pragma clang diagnostic ignored "-Wdeprecated-declarations"

static CFXMLTreeRef
node (CFXMLNodeTypeCode type, CFStringRef str, const void *info)
{
  CFXMLNodeRef n = CFXMLNodeCreate (NULL, type, str, info,
                                    kCFXMLNodeCurrentVersion);
  CFXMLTreeRef t = CFXMLTreeCreateWithNode (NULL, n);
  CFRelease (n);
  return t;
}

int
main (void)
{
  CFXMLTreeRef doc;
  CFXMLTreeRef root;
  CFXMLTreeRef sub;
  CFXMLDocumentInfo docInfo;
  CFXMLElementInfo rootInfo;
  CFXMLElementInfo subInfo;
  CFStringRef keys[1];
  CFStringRef vals[1];
  CFDataRef data;

  docInfo.sourceURL = NULL;
  docInfo.encoding = kCFStringEncodingUTF8;
  doc = node (kCFXMLNodeTypeDocument, CFSTR (""), &docInfo);

  keys[0] = CFSTR ("a");
  vals[0] = CFSTR ("1");
  rootInfo.attributes = CFDictionaryCreate (NULL, (const void **)keys,
    (const void **)vals, 1, &kCFTypeDictionaryKeyCallBacks,
    &kCFTypeDictionaryValueCallBacks);
  rootInfo.attributeOrder = CFArrayCreate (NULL, (const void **)keys, 1,
    &kCFTypeArrayCallBacks);
  rootInfo.isEmpty = false;
  root = node (kCFXMLNodeTypeElement, CFSTR ("root"), &rootInfo);
  CFTreeAppendChild (doc, root);

  CFTreeAppendChild (root, node (kCFXMLNodeTypeText, CFSTR ("x & y <z>"),
                                 NULL));

  subInfo.attributes = NULL;
  subInfo.attributeOrder = NULL;
  subInfo.isEmpty = true;
  sub = node (kCFXMLNodeTypeElement, CFSTR ("sub"), &subInfo);
  CFTreeAppendChild (root, sub);

  CFTreeAppendChild (root, node (kCFXMLNodeTypeComment, CFSTR ("c"), NULL));

  data = CFXMLTreeCreateXMLData (NULL, doc);
  if (data == NULL)
    {
      printf ("SERIALIZED: (null)\n");
    }
  else
    {
      CFIndex len = CFDataGetLength (data);
      const UInt8 *b = CFDataGetBytePtr (data);
      printf ("SERIALIZED len=%ld:\n[", (long)len);
      fwrite (b, 1, len, stdout);
      printf ("]\n");
      CFRelease (data);
    }

  printf ("PROBE DONE\n");
  return 0;
}
