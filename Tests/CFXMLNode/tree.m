#include <CoreFoundation/CFXMLNode.h>
#include <CoreFoundation/CFString.h>

#include "../CFTesting.h"

int main (void)
{
  CFXMLNodeRef node;
  CFXMLTreeRef tree;

  node = CFXMLNodeCreate (NULL, kCFXMLNodeTypeText, CFSTR ("hello"), NULL,
                          kCFXMLNodeCurrentVersion);
  tree = CFXMLTreeCreateWithNode (NULL, node);
  PASS_CF(tree != NULL, "Created an XML tree from a node.");
  PASS_CF(CFXMLTreeGetNode (tree) == node,
          "CFXMLTreeGetNode returns the node the tree was created with.");
  CFRelease (tree);
  CFRelease (node);

  return 0;
}
