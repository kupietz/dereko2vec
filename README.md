# dereko2vec

Fork of [wang2vec](https://github.com/wlin12/wang2vec) with extensions for re-training and count based models, support for tokens with frequencies > 2³² and a more accurate ETA prognosis.

## Installation

### Dependencies

* cmake3
* [libcollocaltordb](https://korap.ids-mannheim.de/gerrit/plugins/gitiles/ids-kl/collocatordb) >= v1.3.0

### Build and install

```bash
cd dereko2vec
mkdir build
cd build
cmake ..
make && ctest3 --extra-verbose && sudo make install
```

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

For example:

```bash
dereko2vec -train new.traindata -output new.vecs -save-net new.net -type 3 -size 200 -window 5 -negative 10 -threads 44 -binary 1 -iter 100 -read-vocab old.vocab -read-net old.net
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
