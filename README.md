# dereko2vec

Fork of [wang2vec](https://github.com/wlin12/wang2vec) with extensions for re-training and count based models, support for tokens with frequencies > 2³² and a more accurate ETA prognosis.

## Installation

### Dependencies

* cmake
* rocksdb. `librocksdb-dev` on Debian and Ubuntu and `rocksdb-devel` on Fedora
  do. Rocky Linux and RHEL package a rocksdb that is too old, there it has to
  be built, which the
  [collocatordb README](https://korap.ids-mannheim.de/gerrit/plugins/gitiles/ids-kl/collocatordb)
  describes
* [libcollocatordb](https://korap.ids-mannheim.de/gerrit/plugins/gitiles/ids-kl/collocatordb) >= v1.6.0

It has to be the same rocksdb that collocatordb was built against. dereko2vec
itself does not include any rocksdb header, but it links what collocatordb
refers to, and symbols of one version do not exist in another.

### Build and install

```bash
cmake -S . -B build
cmake --build build -j $(nproc)
ctest --test-dir build --extra-verbose
sudo cmake --install build
```

This installs `dereko2vec` and `vecs2mmap`. The build directory has to be
`build` inside the sources, the test looks for the binary relative to it.

Where rocksdb or collocatordb were installed into a prefix of their own, name
it, which covers the libraries and the header at once. Several prefixes are
separated by semicolons:

```bash
cmake -S . -B build -DCMAKE_PREFIX_PATH=$HOME/rocksdb
```

### Faster indexing

Linking rocksdb and collocatordb statically makes counting collocations about
22% faster, measured with 2 million increments against rocksdb 7.8.3. On an
indexing run of two weeks that is about three days. Name the two static
libraries, the compression libraries stay shared:

```bash
cmake -S . -B build \
      -DCOLLOCATORDB=/usr/local/lib64/libcollocatordb_static.a \
      -DROCKSDB=$HOME/rocksdb/lib64/librocksdb.a
```

`lib64` on Fedora, Rocky Linux and RHEL, `lib` on Debian and Ubuntu. Debian and
Ubuntu ship `librocksdb.a` in `librocksdb-dev`, elsewhere it comes out of a
rocksdb built by hand, see the collocatordb README.

This does not need static versions of zlib, snappy, lz4 and zstd, which Rocky
Linux, RHEL and Fedora do not ship. Only `-DSTATIC_DEREKO2VEC=ON`, which builds
a completely static binary, needs those, and is rarely worth the trouble.

### If dereko2vec does not start

```
error while loading shared libraries: libcollocatordb.so.1
```

means the loader does not search the directory the library was installed to.
The installed `dereko2vec` carries the directory of the collocatordb it was
linked against, so this only happens with a binary that was built before that,
or when it is the rocksdb below that library which is not found. Either run
`sudo ldconfig` after installing collocatordb, or add the directory:

```bash
echo $HOME/rocksdb/lib64 | sudo tee /etc/ld.so.conf.d/rocksdb.conf
sudo ldconfig
```

A statically linked `dereko2vec` has neither problem.

## Run

The command to build word embeddings is exactly the same as in the original version, except that we added type 5 for setting up a purely count based collocation database.

The -type argument is a integer that defines the architecture to use. These are the possible parameters:  
0 - cbow  
1 - skipngram  
2 - cwindow (see below)  
3 - structured skipngram(see below)  
4 - collobert's senna context window model (still experimental)  
5 - build a collocation count database instead of word embeddings

### Example

```bash
./dereko2vec -train input_file -output embedding_file -type 0 -size 50 -window 5 -negative 10 -nce 0 -hs 0 -sample 1e-4 -threads 1 -binary 1 -iter 5 -cap 0
```

## Generate dereko2vec training input files from KorAP-XML ZIPs

The [KorAP-XML-CoNLL-U](https://github.com/KorAP/KorAP-XML-CoNLL-U) tool can be used to generate input files for dereko2vec from KorAP-XML ZIPs using its tokenization and setence boundary information, for example:

```bash
korapxml2conllu --word2vec wpd19.zip > wpd19.w2vinput
```

## Retrain existing model with new data

### For example:
### Retrain Vectors:

```bash
dereko2vec -train new.traindata -output new.vecs -save-net new.net -type 3 -size 200 -window 5 -negative 10 -threads 44 -binary 1 -iter 100 -read-vocab old.vocab -read-net old.net
```

### Create new RocksDB:

```bash
dereko2vec -train new.traindata -output new.rocksdb -type 5 -window 5 -threads 8 -binary 1 -iter 1 -read-vocab old.vocab -sample 0 -min-count 0
dereko2vec -train new.traindata -output .temp.rocksdb -type 5 -window 5 -threads 8 -binary 1 -iter 1 -save-vocab new_focus.vocab -sample 0 -min-count 0
rm -rf .temp.rocksdb
python scripts/merge_vocabs.py old.vocab new_focus.vocab new.vocab
```

## References

```bash
@InProceedings{Ling:2015:naacl,  
author = {Ling, Wang and Dyer, Chris and Black, Alan and Trancoso, Isabel},  
title="Two/Too Simple Adaptations of word2vec for Syntax Problems",  
booktitle="Proceedings of the 2015 Conference of the North American Chapter of the Association for Computational Linguistics: Human Language Technologies",  
year="2015",  
publisher="Association for Computational Linguistics",  
location="Denver, Colorado",  
}

@InProceedings{FankhauserKupietz2019,
author    = {Peter Fankhauser and Marc Kupietz},
title     = {Analyzing domain specific word embeddings for a large corpus of contemporary German},
series = {Proceedings of the 10th International Corpus Linguistics Conference},
publisher = {University of Cardiff},
address   = {Cardiff},
year      = {2019},
note      = {\url{https://doi.org/10.14618/ids-pub-9117}}
}
```
