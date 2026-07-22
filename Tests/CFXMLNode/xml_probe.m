#include <CoreFoundation/CFXMLNode.h>
#include <CoreFoundation/CFString.h>
#include <CoreFoundation/CFDictionary.h>
#include <CoreFoundation/CFArray.h>
#include <stdio.h>

static void
pstr (const char *label, CFStringRef s)
{
  char buf[128] = {0};
  if (s)
    CFStringGetCString (s, buf, sizeof buf, kCFStringEncodingUTF8);
  printf ("%s='%s'\n", label, s ? buf : "(null)");
}

int
main (void)
{
  CFXMLNodeRef text = CFXMLNodeCreate (NULL, kCFXMLNodeTypeText, CFSTR ("hello"),
                                       NULL, kCFXMLNodeCurrentVersion);
  printf ("text typeCode=%ld (expect 6)\n",
          (long)CFXMLNodeGetTypeCode (text));
  pstr ("text string", CFXMLNodeGetString (text));
  printf ("text infoPtr=%s\n", CFXMLNodeGetInfoPtr (text) ? "nonNULL" : "NULL");
  printf ("text version=%ld\n", (long)CFXMLNodeGetVersion (text));
  printf ("node CFGetTypeID==CFXMLNodeGetTypeID? %d\n",
          CFGetTypeID (text) == CFXMLNodeGetTypeID ());

  CFXMLNodeRef textCopy = CFXMLNodeCreateCopy (NULL, text);
  printf ("text CFEqual(copy)=%d\n", CFEqual (text, textCopy));
  printf ("textCopy typeCode=%ld\n", (long)CFXMLNodeGetTypeCode (textCopy));

  CFXMLNodeRef comment = CFXMLNodeCreate (NULL, kCFXMLNodeTypeComment,
                                          CFSTR ("cmt"), NULL, 1);
  printf ("comment typeCode=%ld (expect 5) infoPtr=%s\n",
          (long)CFXMLNodeGetTypeCode (comment),
          CFXMLNodeGetInfoPtr (comment) ? "nonNULL" : "NULL");

  CFStringRef keys[1] = { CFSTR ("id") };
  CFStringRef vals[1] = { CFSTR ("1") };
  CFDictionaryRef attrs =
    CFDictionaryCreate (NULL, (const void **)keys, (const void **)vals, 1,
                        &kCFTypeDictionaryKeyCallBacks,
                        &kCFTypeDictionaryValueCallBacks);
  CFArrayRef order =
    CFArrayCreate (NULL, (const void **)keys, 1, &kCFTypeArrayCallBacks);
  CFXMLElementInfo einfo = { attrs, order, false };
  CFXMLNodeRef elem = CFXMLNodeCreate (NULL, kCFXMLNodeTypeElement,
                                       CFSTR ("tag"), &einfo, 1);
  printf ("elem typeCode=%ld (expect 2)\n", (long)CFXMLNodeGetTypeCode (elem));
  pstr ("elem string", CFXMLNodeGetString (elem));
  const CFXMLElementInfo *ei =
    (const CFXMLElementInfo *)CFXMLNodeGetInfoPtr (elem);
  printf ("elem infoPtr=%s\n", ei ? "nonNULL" : "NULL");
  if (ei)
    {
      printf ("elem attrs count=%ld isEmpty=%d attrOrder count=%ld\n",
              ei->attributes ? (long)CFDictionaryGetCount (ei->attributes) : -1,
              ei->isEmpty,
              ei->attributeOrder ? (long)CFArrayGetCount (ei->attributeOrder)
                                 : -1);
      printf ("elem attrs same ptr as input? %d (copy expected 0)\n",
              ei->attributes == attrs);
    }
  CFXMLNodeRef elemCopy = CFXMLNodeCreateCopy (NULL, elem);
  printf ("elem CFEqual(copy)=%d\n", CFEqual (elem, elemCopy));

  CFXMLProcessingInstructionInfo piinfo = { CFSTR ("pidata") };
  CFXMLNodeRef pi = CFXMLNodeCreate (NULL, kCFXMLNodeTypeProcessingInstruction,
                                     CFSTR ("pitarget"), &piinfo, 1);
  printf ("pi typeCode=%ld (expect 4)\n", (long)CFXMLNodeGetTypeCode (pi));
  const CFXMLProcessingInstructionInfo *pip =
    (const CFXMLProcessingInstructionInfo *)CFXMLNodeGetInfoPtr (pi);
  pstr ("pi dataString", pip ? pip->dataString : NULL);

  CFXMLNodeRef v2 = CFXMLNodeCreate (NULL, kCFXMLNodeTypeText, CFSTR ("x"),
                                     NULL, 2);
  printf ("v2 version=%ld (passed 2)\n", (long)CFXMLNodeGetVersion (v2));

  CFXMLTreeRef tree = CFXMLTreeCreateWithNode (NULL, text);
  CFXMLNodeRef tn = CFXMLTreeGetNode (tree);
  printf ("tree node == text ptr? %d ; CFEqual? %d\n", tn == text,
          tn ? CFEqual (tn, text) : -1);

  printf ("PROBE DONE\n");
  return 0;
}
