FROM amazonlinux:2018.03

RUN yum update -y && \
    yum install -y \\
        atlas-devel atlas-sse3-devel \
        gcc gcc-c++ \
        blas-devel lapack-devel \
        python36-devel python36-virtualenv \
        findutils zip && \
    /usr/bin/virtualenv-3.6 \
        --python /usr/bin/python36 /lambda \
        --always-copy --no-site-packages && \
    source /lambda/bin/activate && \
    pip-3.6 install --no-binary numpy numpy && \
    pip-3.6 install --no-binary scipy scipy
