#!/bin/bash
PIP="pip-3.6"

set -ex

do_pip () {
  test -f /outputs/requirements.txt && $PIP install -r /outputs/requirements.txt
}

strip_virtualenv () {
    # Clean up docs
    find $VIRTUAL_ENV -name "*.dist-info" -type d -prune -exec rm -rf {} \;
    echo "venv stripped size $(du -sh $VIRTUAL_ENV | cut -f1)"

    # Clean up tests
    find $VIRTUAL_ENV -name "tests" -type d -prune -exec rm -rf {} \;
    echo "venv stripped size $(du -sh $VIRTUAL_ENV | cut -f1)"

    echo "venv original size $(du -sh $VIRTUAL_ENV | cut -f1)"
    find $VIRTUAL_ENV/lib64/python3.6/site-packages/ -name "*.so" | xargs strip
    echo "venv stripped size $(du -sh $VIRTUAL_ENV | cut -f1)"

    cp /outputs/process.py $VIRTUAL_ENV

    pushd $VIRTUAL_ENV && zip -r -9 -q /tmp/process.zip process.py ; popd
    pushd $VIRTUAL_ENV/lib/python3.6/site-packages/ && zip -r -9 --out /tmp/partial-venv.zip -q /tmp/process.zip * ; popd
    pushd $VIRTUAL_ENV/lib64/python3.6/site-packages/ && zip -r -9 --out /outputs/venv.zip -q /tmp/partial-venv.zip * ; popd
    echo "site-packages compressed size $(du -sh /outputs/venv.zip | cut -f1)"

    pushd $VIRTUAL_ENV && zip -r -q /outputs/full-venv.zip * ; popd
    echo "venv compressed size $(du -sh /outputs/full-venv.zip | cut -f1)"
}

shared_libs () {
    libdir="$VIRTUAL_ENV/lib64/python3.6/site-packages/lib/"
    mkdir -p $VIRTUAL_ENV/lib64/python3.6/site-packages/lib || true
    cp /usr/lib64/atlas/* $libdir
    cp /usr/lib64/libquadmath.so.0 $libdir
    cp /usr/lib64/libgfortran.so.3 $libdir
}

main () {
    /usr/bin/virtualenv-3.6 \
        --python /usr/bin/python36 /lambda \
        --always-copy \
        --no-site-packages
    source /lambda/bin/activate

    do_pip

    shared_libs

    strip_virtualenv

}
main
