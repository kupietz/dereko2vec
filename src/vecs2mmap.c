/* Writes the memory mappable form of an already trained model, so that
 * derekovecs does not have to build it itself on its first start. dereko2vec
 * does this right after training, this tool is for models that were trained
 * before, or whose converted files were lost.
 */

#include <stdio.h>
#include <string.h>

#include "mmap_vecs.h"

int main(int argc, char **argv) {
  int i;

  if (argc < 2 || strcmp(argv[1], "-h") == 0) {
    printf("usage: %s <model.vecs> [<model.vecs> ...]\n\n"
           "Writes <model.vecs>.vecs and <model.vecs>.words, the memory\n"
           "mappable form derekovecs uses.\n", argv[0]);
    return argc < 2 ? 1 : 0;
  }

  for (i = 1; i < argc; i++) {
    printf("Converting %s to memory mappable structures\n", argv[i]);
    fflush(stdout);
    if (convert_vecs_to_mmap(argv[i]) != 0)
      return 1;
  }
  return 0;
}
