# SPDX-FileCopyrightText: © 2025 VEXXHOST, Inc.
# SPDX-License-Identifier: GPL-3.0-or-later
# Atmosphere-Rebuild-Time: 2024-06-25T22:49:25Z

FROM ghcr.io/vexxhost/openstack-venv-builder:zed@sha256:be88bcb991b90058e3b35ecdc22d10e2470c7f617340daa0cc3f77374ef2c47c AS build
RUN --mount=type=bind,from=barbican,source=/,target=/src/barbican,readwrite <<EOF bash -xe
uv pip install \
    --constraint /upper-constraints.txt \
        /src/barbican \
        pykmip
EOF

FROM ghcr.io/vexxhost/python-base:zed@sha256:d9e5a65f338e0c1f6754d9a32ed37b9e23485c00ad4ce8afb81c49689288fcf8
RUN \
    groupadd -g 42424 barbican && \
    useradd -u 42424 -g 42424 -M -d /var/lib/barbican -s /usr/sbin/nologin -c "Barbican User" barbican && \
    mkdir -p /etc/barbican /var/log/barbican /var/lib/barbican /var/cache/barbican && \
    chown -Rv barbican:barbican /etc/barbican /var/log/barbican /var/lib/barbican /var/cache/barbican
COPY --from=build --link /var/lib/openstack /var/lib/openstack
