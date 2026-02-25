# SPDX-FileCopyrightText: © 2025 VEXXHOST, Inc.
# SPDX-License-Identifier: GPL-3.0-or-later
# Atmosphere-Rebuild-Time: 2024-06-25T22:49:25Z

FROM ghcr.io/vexxhost/openstack-venv-builder:zed@sha256:e2a2b3a7d41083f92b0139920a30c65cfee97b7db9ec2f20e7150c45dfcb4259 AS build
RUN --mount=type=bind,from=barbican,source=/,target=/src/barbican,readwrite <<EOF bash -xe
uv pip install \
    --constraint /upper-constraints.txt \
        /src/barbican \
        pykmip
EOF

FROM ghcr.io/vexxhost/python-base:zed@sha256:43e13657031dc049e919108abdb5e70dbff13d31aef7f297bc45bdadf9330862
RUN \
    groupadd -g 42424 barbican && \
    useradd -u 42424 -g 42424 -M -d /var/lib/barbican -s /usr/sbin/nologin -c "Barbican User" barbican && \
    mkdir -p /etc/barbican /var/log/barbican /var/lib/barbican /var/cache/barbican && \
    chown -Rv barbican:barbican /etc/barbican /var/log/barbican /var/lib/barbican /var/cache/barbican
COPY --from=build --link /var/lib/openstack /var/lib/openstack
