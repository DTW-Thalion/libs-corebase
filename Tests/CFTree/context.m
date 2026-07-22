#include <CoreFoundation/CFTree.h>
#include <CoreFoundation/CFString.h>

#include "../CFTesting.h"

int main (void)
{
  CFStringRef info;
  CFTreeContext ctx;
  CFTreeContext out;
  CFTreeRef tree;
  CFIndex rc0;

  info = CFStringCreateWithCString (NULL, "node", kCFStringEncodingUTF8);
  rc0 = CFGetRetainCount (info);

  ctx.version = 0;
  ctx.info = (void *)info;
  ctx.retain = CFRetain;
  ctx.release = CFRelease;
  ctx.copyDescription = CFCopyDescription;

  tree = CFTreeCreate (NULL, &ctx);
  PASS_CF(tree != NULL, "Created a tree with a context.");
  PASS_CF(CFGetRetainCount (info) == rc0 + 1,
          "CFTreeCreate retains the context info.");

  CFTreeGetContext (tree, &out);
  PASS_CF(out.info == (void *)info, "CFTreeGetContext returns the info.");

  CFRelease (tree);
  PASS_CF(CFGetRetainCount (info) == rc0,
          "Releasing the tree releases the context info once.");

  CFRelease (info);

  return 0;
}
