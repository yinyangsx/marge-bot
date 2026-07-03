FROM harbor.infiscale.dev/library/ubuntu:24.04

ARG APT_MIRROR_URL=http://10.10.201.12/ubuntu
ARG PIP_INDEX_URL=https://pypi.infiscale.dev/simple
ARG PIP_TRUSTED_HOST=pypi.infiscale.dev

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_INDEX_URL=${PIP_INDEX_URL} \
    PIP_TRUSTED_HOST=${PIP_TRUSTED_HOST} \
    PATH=/opt/venv/bin:$PATH \
    GIT_SSL_CAINFO=/etc/ssl/certs/ca-certificates.crt \
    SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

RUN sed -i \
        -e "s|http://mirrors.aliyun.com/ubuntu|${APT_MIRROR_URL}|g" \
        -e "s|http://mirrors.aliyun.com/ubuntu|${APT_MIRROR_URL}|g" \
        /etc/apt/sources.list.d/ubuntu.sources \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        openssh-client \
        python3 \
        python3-pip \
        python3-venv \
    && python3 -m venv /opt/venv \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt setup.py version marge.app ./
COPY marge ./marge

RUN pip install --upgrade pip \
    && pip install -r requirements.txt \
    && pip install .

ENTRYPOINT ["marge.app"]
