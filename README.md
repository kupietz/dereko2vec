# dereko2vec
Fork of [wang2vec](https://github.com/wlin12/wang2vec) with extensions for re-training and count based models and a 
more accurate ETA prognosis.

## Installation
### Dependencies
* cmake3
* [libcollocaltordb](https://korap.ids-mannheim.de/gerrit/plugins/gitiles/ids-kl/collocatordb) >= v1.3.0
### Build and install
```
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
```
./dereko2vec -train input_file -output embedding_file -type 0 -size 50 -window 5 -negative 10 -nce 0 -hs 0 -sample 1e-4 -threads 1 -binary 1 -iter 5 -cap 0
```


## References
```
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
