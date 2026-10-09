# ipython and jupyter. The subcommands of jupyter are the jupyter-* programs in PATH (stood in for here).
__luish_internal plugin load "$EXTRA/completion/science"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
mkdir bin
for x in lab notebook nbconvert kernelspec execute; do printf '#!/bin/sh\n' >bin/jupyter-$x; chmod +x bin/jupyter-$x; done
touch bin/jupyter-lab.py
mkdir work
touch analysis.ipynb model.py setup.ipy notes.txt report.html
PATH=$PWD/bin    # only these: the jupyter-* programs of the machine would be subcommands too
echo "=== jupyter"
c 'jupyter '
c 'jupyter n'
c 'jupyter -'
c 'jupyter nbconvert --to '
c 'jupyter nbconvert --to p'
c 'jupyter nbconvert --'
c 'jupyter nbconvert --output-dir '
c 'jupyter nbconvert --log-level '
c 'jupyter nbconvert '
c 'jupyter lab --no-'
c 'jupyter lab --notebook-dir '
c 'jupyter lab --port '
c 'jupyter kernelspec '
c 'jupyter kernelspec l'
c 'jupyter execute --'
c 'jupyter-nbconvert --to l'
c 'jupyter-lab --config '
echo "=== ipython"
c 'ipython '
c 'ipython pro'
c 'ipython profile '
c 'ipython history '
c 'ipython --col'
c 'ipython --colors '
c 'ipython --profile-dir '
c 'ipython --no-'
c 'ipython -i mo'
c 'ipython --matplotlib '
