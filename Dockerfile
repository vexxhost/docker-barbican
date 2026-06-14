# SPDX-FileCopyrightText: © 2025 VEXXHOST, Inc.
# SPDX-License-Identifier: GPL-3.0-or-later

FROM ghcr.io/vexxhost/openstack-venv-builder:2025.1@sha256:c8fce46ccda5251f5c59006603cc0594599b2d73b65eabbc8d73bec103846541 AS build
RUN --mount=type=bind,from=barbican,source=/,target=/src/barbican,readwrite <<EOF bash -xe
uv pip install \
    --constraint /upper-constraints.txt \
        /src/barbican \
        pykmip
EOF

FROM ghcr.io/vexxhost/python-base:2025.1@sha256:aa2dc02c5662a08071a27d11ecc1bc9d9690c68c6006caa48c18fb9501818bc3
RUN \
    groupadd -g 42424 barbican && \
    useradd -u 42424 -g 42424 -M -d /var/lib/barbican -s /usr/sbin/nologin -c "Barbican User" barbican && \
    mkdir -p /etc/barbican /var/log/barbican /var/lib/barbican /var/cache/barbican && \
    chown -Rv barbican:barbican /etc/barbican /var/log/barbican /var/lib/barbican /var/cache/barbican
COPY --from=build --link /var/lib/openstack /var/lib/openstack
