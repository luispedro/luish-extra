# coverage (its commands, `run`'s program or module, `debug`'s topics), and Cython's cython and cythonize (the
# compiler directives of -X).
__luish_internal plugin load "$EXTRA/completion/dev"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
mkdir -p pkg build
touch pkg/__init__.py pkg/fast.pyx pkg/fast.pxd pkg/fast.c main.py notes.md .coveragerc
echo "=== coverage"
c 'coverage '
c 'coverage run '
c 'coverage run --'
c 'coverage run -m '
c 'coverage run --concurrency '
c 'coverage run --concurrency thread,m'
c 'coverage run --save-signal '
c 'coverage report --format '
c 'coverage report --sort='
c 'coverage report pkg/'
c 'coverage html -d '
c 'coverage debug '
c 'coverage help '
c 'coverage combine --'
echo "=== cython"
c 'cython '
c 'cython pkg/'
c 'cython -X '
c 'cython -X bound'
c 'cython -X boundscheck='
c 'cython -X boundscheck=False,language_level='
c 'cython --directive=c_string_type='
c 'cython --emb'
c 'cython -I '
c 'cython -W'
echo "=== cythonize"
c 'cythonize '
c 'cythonize -i pkg/'
c 'cythonize -X wrap'
c 'cythonize --'
