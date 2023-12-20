#!/usr/bin/env bash
TESTDIR=$(dirname $0)
ASSERTSH=${TESTDIR}/assert.sh
set -e
. ${ASSERTSH}

DESTDIR=$(mktemp -d)
trap '{ rm -rf -- "$DESTDIR"; }' EXIT
DATADIR=${TESTDIR}/data
BUILDDIR=$(realpath ${TESTDIR}/../build)
echo $BUILDDIR >out

${BUILDDIR}/dereko2vec -train ${DATADIR}/wpd19_10000.w2vinput -output ${DESTDIR}/wpd19_10000.vecs -type 3 \
  -save-net ${DESTDIR}/wpd19_10000.net -save-vocab ${DESTDIR}/wpd19_10000.vocab \
  -size 200 -binary 1 -window 5 -negative 10 -threads 16 -iter 5 -min-count 2 \
  > >(tee -a ${BUILDDIR}/stdout.log) 2> >(tee -a ${BUILDDIR}/stderr.log >&2)


stdoutlog=$(cat ${BUILDDIR}/stdout.log)
assert_contain "$stdoutlog" "ETA:"
if [ "$?" == 0 ]; then
  log_success "dereko2vec prints ETA"
else
  log_failure "dereko2vec does not print ETA"
fi

assert_contain "$stdoutlog" "Finished"
if [ "$?" == 0 ]; then
  log_success "dereko2vec can build word embedding model"
else
  log_failure "dereko2vec cannot build word embedding model"
fi

observed=$(cat ${DESTDIR}/wpd19_10000.vocab)
#expected=$(cat ${DATADIR}/wpd19_10000.vocab)
#assert_eq "$observed" "$expected" "wrong vocab output!"
#if [ "$?" == 1 ]; then
#    log_success "vocab output is identical with wpd19_10000.vocab"
#  else
#    log_failure "vocab output should be identical with wpd19_10000.vocab"
#fi

observed=$(echo -e "Grund\nEXIT" | ${BUILDDIR}/distance ${DESTDIR}/wpd19_10000.vecs)

assert_contain "$observed" "Zusammenhang"
if [ "$?" == 0 ]; then
  log_success "neighbours of Grund contain Zusammenhang"
else
  log_failure "neighbours of Grund should contain Zusammenhang"
fi

assert_not_contain "$observed" "gestern"
if [ "$?" == 0 ]; then
  log_success "neighbours of Grund do not contain gestern"
else
  log_failure "neighbours of Grund should not contain gestern"
fi

${BUILDDIR}/dereko2vec -train ${DATADIR}/wpd19_10000.w2vinput -output ${DESTDIR}/wpd19_10000.rocksdb -type 5 \
  -read-vocab ${DESTDIR}/wpd19_10000.vocab -threads 8 \
  > >(tee -a ${BUILDDIR}/stdout.log) 2> >(tee -a ${BUILDDIR}/stderr.log >&2)

stdoutlog=$(cat ${BUILDDIR}/stdout.log)
assert_contain "$stdoutlog" "Finished"
if [ "$?" == 0 ]; then
  log_success "dereko2vec can build count based collocation database"
else
  log_failure "dereko2vec cannot build count based collocation database"
fi
