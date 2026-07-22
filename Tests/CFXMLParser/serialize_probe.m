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

static void
emit (const char *label, CFXMLTreeRef doc)
{
  CFDataRef data = CFXMLTreeCreateXMLData (NULL, doc);
  printf ("%s: [", label);
  if (data)
    {
      fwrite (CFDataGetBytePtr (data), 1, CFDataGetLength (data), stdout);
      CFRelease (data);
    }
  printf ("]\n");
}

int
main (void)
{
  CFXMLDocumentInfo di;
  CFXMLElementInfo ei;
  CFXMLProcessingInstructionInfo pi;
  CFStringRef keys[2];
  CFStringRef vals[2];
  CFXMLTreeRef doc;
  CFXMLTreeRef e;

  di.sourceURL = NULL;
  di.encoding = kCFStringEncodingUTF8;

  /* Element with no attributes and a text child. */
  doc = node (kCFXMLNodeTypeDocument, CFSTR (""), &di);
  ei.attributes = NULL; ei.attributeOrder = NULL; ei.isEmpty = false;
  e = node (kCFXMLNodeTypeElement, CFSTR ("e"), &ei);
  CFTreeAppendChild (doc, e);
  CFTreeAppendChild (e, node (kCFXMLNodeTypeText, CFSTR ("t"), NULL));
  emit ("no-attr element", doc);

  /* Two attributes; does the value get escaped? */
  doc = node (kCFXMLNodeTypeDocument, CFSTR (""), &di);
  keys[0] = CFSTR ("x"); vals[0] = CFSTR ("1");
  keys[1] = CFSTR ("y"); vals[1] = CFSTR ("a&b\"c");
  ei.attributes = CFDictionaryCreate (NULL, (const void **)keys,
    (const void **)vals, 2, &kCFTypeDictionaryKeyCallBacks,
    &kCFTypeDictionaryValueCallBacks);
  ei.attributeOrder = CFArrayCreate (NULL, (const void **)keys, 2,
    &kCFTypeArrayCallBacks);
  ei.isEmpty = true;
  CFTreeAppendChild (doc, node (kCFXMLNodeTypeElement, CFSTR ("m"), &ei));
  emit ("two-attr empty element", doc);

  /* Processing instruction: node string is the target, info has the data. */
  doc = node (kCFXMLNodeTypeDocument, CFSTR (""), &di);
  pi.dataString = CFSTR ("type=\"text/xsl\"");
  CFTreeAppendChild (doc, node (kCFXMLNodeTypeProcessingInstruction,
                                CFSTR ("xml-stylesheet"), &pi));
  emit ("processing instruction", doc);

  /* CDATA section. */
  doc = node (kCFXMLNodeTypeDocument, CFSTR (""), &di);
  CFTreeAppendChild (doc, node (kCFXMLNodeTypeCDATASection,
                                CFSTR ("a<b>&c"), NULL));
  emit ("cdata section", doc);

  printf ("PROBE DONE\n");
  return 0;
}
