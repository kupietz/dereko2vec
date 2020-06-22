CC = gcc
#Using -Ofast instead of -O3 might result in faster code, but is supported only by newer GCC versions
CFLAGS = -lm -pthread -O3 -march=native -mtune=native -Wall -funroll-loops
#CFLAGS = -m64 -march=k8 -mtune=k8 -lm -pthread -O3 -Wall -funroll-loops 
STATICCDB=../../CollocatorDB
ROCKSDB=/usr/local/lib

all: word2vec word2vec1 cngram2vec weightedWord2vec wordless2vec word2phrase distance word-analogy compute-accuracy distance_txt distance_fast kmeans_txt

word2vec : word2vecExt.c makefile $(STATICCDB)/libcollocatordb.a
	$(CC) $(CFLAGS) word2vecExt.c $(STATICCDB)/libcollocatordb.a $(ROCKSDB)/librocksdb.a -o word2vec -I$(STATICCDB) -L$(STATICCDB) -L/usr/local/lib -ldl -lstdc++ -lm -lrt -lsnappy -lz -lbz2 -llz4 -lzstd

word2vec1 : word2vecExt1.c makefile $(STATICCDB)/libcollocatordb.a
	$(CC) $(CFLAGS) word2vecExt1.c $(STATICCDB)/libcollocatordb.a $(ROCKSDB)/librocksdb.a -o word2vec1 -I$(STATICCDB) -L$(STATICCDB) -L/usr/local/lib -ldl -lstdc++ -lm -lrt -lsnappy -lz -lbz2 -llz4 -lzstd

weightedWord2vec : weightedWord2vec.c
	$(CC) weightedWord2vec.c -o weightedWord2vec $(CFLAGS)
cngram2vec : cngram2vec.c
	$(CC) cngram2vec.c -o cngram2vec $(CFLAGS)
wordless2vec : wordless2vec.c
	$(CC) wordless2vec.c -o wordless2vec $(CFLAGS)
word2phrase : word2phrase.c
	$(CC) word2phrase.c -o word2phrase $(CFLAGS)
distance : distance.c
	$(CC) distance.c -o distance $(CFLAGS)
distance_txt : distance_txt.c
	$(CC) distance_txt.c -o distance_txt $(CFLAGS)
distance_fast : distance_fast.c
	$(CC) distance_fast.c -o distance_fast $(CFLAGS)
kmeans_txt : kmeans_txt.c
	$(CC) kmeans_txt.c -o kmeans_txt $(CFLAGS)
word-analogy : word-analogy.c
	$(CC) word-analogy.c -o word-analogy $(CFLAGS)
compute-accuracy : compute-accuracy.c
	$(CC) compute-accuracy.c -o compute-accuracy $(CFLAGS)
clean:
	rm -rf word2vec word2vec1 weightedWord2vec cngram2vec wiord2phrase distance word-analogy compute-accuracy distance_txt kmeans_txt
