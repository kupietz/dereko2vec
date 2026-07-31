/* Writes the memory mappable form of a model next to the model file:
 *
 *   <model>.vecs   words * size floats, every word vector normalized to length 1
 *   <model>.words  words * MMAP_MAX_W bytes, the word, NUL terminated and padded
 *
 * derekovecs memory maps these two files. When they are missing it builds them
 * itself on its first start, which takes a while and needs write access to the
 * directory the models live in - which a server does not necessarily have.
 *
 * The conversion deliberately mirrors init_net() of derekovecs, including the
 * order of the floating point operations, so that both produce the same files.
 */

#ifndef MMAP_VECS_H
#define MMAP_VECS_H

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* has to match max_w in derekovecs */
#define MMAP_MAX_W 50

/* Reads the model written by SaveVectors() and writes its memory mappable
 * form. Returns 0 on success. */
static int convert_vecs_to_mmap(const char *file_name) {
  FILE *f, *binvecs, *binwords;
  char binvecs_fname[4096], binwords_fname[4096];
  long long words, size, a, b;
  float len, *M;
  char *vocab;
  double val;
  int is_text = (strstr(file_name, ".txt") != NULL);

  snprintf(binvecs_fname, sizeof(binvecs_fname), "%s.vecs", file_name);
  snprintf(binwords_fname, sizeof(binwords_fname), "%s.words", file_name);

  if ((f = fopen(file_name, "rb")) == NULL) {
    fprintf(stderr, "Cannot open %s for the memory mappable conversion\n", file_name);
    return -1;
  }
  if (fscanf(f, "%lld", &words) != 1 || fscanf(f, "%lld", &size) != 1) {
    fprintf(stderr, "Cannot read the header of %s\n", file_name);
    fclose(f);
    return -1;
  }

  vocab = (char *)calloc((size_t)words * MMAP_MAX_W, sizeof(char));
  M = (float *)malloc((size_t)words * (size_t)size * sizeof(float));
  if (vocab == NULL || M == NULL) {
    fprintf(stderr, "Cannot allocate %lld MB for the memory mappable conversion\n",
            (long long)((size_t)words * size * sizeof(float) / 1048576));
    free(vocab);
    free(M);
    fclose(f);
    return -1;
  }

  for (b = 0; b < words; b++) {
    a = 0;
    while (1) {
      vocab[b * MMAP_MAX_W + a] = fgetc(f);
      if (feof(f) || (vocab[b * MMAP_MAX_W + a] == ' ')) break;
      if ((a < MMAP_MAX_W - 1) && (vocab[b * MMAP_MAX_W + a] != '\n')) a++;
    }
    vocab[b * MMAP_MAX_W + a] = 0;
    len = 0;
    if (is_text) {
      for (a = 0; a < size; a++) {
        if (fscanf(f, "%lf", &val) != 1) val = 0;
        M[a + b * size] = val;
        len += M[a + b * size] * M[a + b * size];
      }
    } else {
      if (fread(&M[b * size], sizeof(float), size, f) != (size_t)size) {
        fprintf(stderr, "Unexpected end of %s at word %lld\n", file_name, b);
        free(vocab);
        free(M);
        fclose(f);
        return -1;
      }
      for (a = 0; a < size; a++) len += M[a + b * size] * M[a + b * size];
    }
    len = sqrt(len);
    if (len > 0)
      for (a = 0; a < size; a++) M[a + b * size] /= len;
  }
  fclose(f);

  if ((binvecs = fopen(binvecs_fname, "wb")) == NULL ||
      (binwords = fopen(binwords_fname, "wb")) == NULL) {
    fprintf(stderr, "Cannot write %s or %s\n", binvecs_fname, binwords_fname);
    free(vocab);
    free(M);
    return -1;
  }
  fwrite(M, sizeof(float), (size_t)words * (size_t)size, binvecs);
  fclose(binvecs);
  fwrite(vocab, sizeof(char), (size_t)words * MMAP_MAX_W, binwords);
  fclose(binwords);

  free(vocab);
  free(M);
  return 0;
}

#endif /* MMAP_VECS_H */
