# syntax=docker/dockerfile:1
# check=skip=FromPlatformFlagConstDisallowed

ARG UBUNTU_VERSION=24.04
ARG NGSPICE_VERSION=ngspice-46
ARG OPENVAF_VERSION=23_5_0
ARG PDK_COMMIT=f7aa209403076543d9c31f43f039e22cf04f424a

# OpenVAF solo se distribuye para amd64
FROM --platform=linux/amd64 ubuntu:${UBUNTU_VERSION} AS builder

ARG NGSPICE_VERSION
ARG OPENVAF_VERSION
ARG PDK_COMMIT
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential autoconf automake libtool bison flex \
        libreadline-dev libfftw3-dev \
        git ca-certificates wget \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch ${NGSPICE_VERSION} \
        https://git.code.sf.net/p/ngspice/ngspice /tmp/ngspice \
    && cd /tmp/ngspice \
    && ./autogen.sh \
    && ./configure --prefix=/opt/ngspice --enable-osdi --enable-pss \
                   --without-x --with-readline=yes --disable-debug \
    && make -j"$(nproc)" \
    && make install

RUN wget -q https://openva.fra1.cdn.digitaloceanspaces.com/openvaf_${OPENVAF_VERSION}_linux_amd64.tar.gz \
        -O /tmp/openvaf.tar.gz \
    && tar -xzf /tmp/openvaf.tar.gz -C /usr/local/bin \
    && chmod +x /usr/local/bin/openvaf

WORKDIR /opt/pdk/IHP-Open-PDK
RUN git init -q \
    && git remote add origin https://github.com/IHP-GmbH/IHP-Open-PDK.git \
    && git fetch -q --depth 1 origin ${PDK_COMMIT} \
    && git checkout -q FETCH_HEAD

RUN cd ihp-sg13g2/libs.tech/verilog-a && ./openvaf-compile-va.sh


FROM --platform=linux/amd64 ubuntu:${UBUNTU_VERSION} AS runtime

ARG NGSPICE_VERSION
ARG OPENVAF_VERSION
ARG PDK_COMMIT
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        libreadline8t64 libfftw3-double3 libgomp1 \
        python3 python3-venv \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/ngspice /opt/ngspice

ARG PDK_DIR=/opt/pdk/IHP-Open-PDK
COPY --from=builder ${PDK_DIR}/LICENSE ${PDK_DIR}/LICENSE
COPY --from=builder ${PDK_DIR}/ihp-sg13g2/libs.tech/ngspice ${PDK_DIR}/ihp-sg13g2/libs.tech/ngspice
COPY --from=builder ${PDK_DIR}/ihp-sg13g2/libs.ref/sg13g2_stdcell/spice ${PDK_DIR}/ihp-sg13g2/libs.ref/sg13g2_stdcell/spice
COPY --from=builder ${PDK_DIR}/ihp-sg13g2/libs.ref/sg13g2_io/spice ${PDK_DIR}/ihp-sg13g2/libs.ref/sg13g2_io/spice

RUN install -d -o ubuntu -g ubuntu /opt/venv
USER ubuntu

RUN python3 -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir numpy==2.3.1 matplotlib==3.10.3

# SPICE_USERINIT_DIR: ngspice carga el .spiceinit del PDK sin depender de $HOME
ENV PDK_ROOT=${PDK_DIR} \
    PDK=ihp-sg13g2 \
    SPICE_USERINIT_DIR=${PDK_DIR}/ihp-sg13g2/libs.tech/ngspice \
    PATH=/opt/venv/bin:/opt/ngspice/bin:${PATH}

LABEL org.opencontainers.image.title="darwin" \
      org.opencontainers.image.description="ngspice + PDK IHP SG13G2 para optimización de circuitos analógicos" \
      proyecto.ngspice.version="${NGSPICE_VERSION}" \
      proyecto.openvaf.version="${OPENVAF_VERSION}" \
      proyecto.pdk.commit="${PDK_COMMIT}"

COPY docker/smoke_test.sp /opt/proyecto/smoke_test.sp
RUN ngspice -b /opt/proyecto/smoke_test.sp | grep -q "id_max"

COPY --chown=ubuntu:ubuntu pyproject.toml README.md LICENSE NOTICE /opt/darwin/
COPY --chown=ubuntu:ubuntu src /opt/darwin/src
RUN pip install --no-cache-dir "/opt/darwin[dev]" \
    && python3 -c "import darwin; print('darwin', darwin.__version__)"

WORKDIR /work

CMD ["bash"]
