# SPDX-FileCopyrightText: © 2025 VEXXHOST, Inc.
# SPDX-License-Identifier: GPL-3.0-or-later
# Atmosphere-Rebuild-Time: 2024-06-25T22:49:25Z

FROM ghcr.io/vexxhost/openstack-venv-builder:2024.2@sha256:1167b3a9e8ce4327f8d1eb8b21172391a49ae70ffbf4460adb666b1285224100 AS build
RUN --mount=type=bind,from=barbican,source=/,target=/src/barbican,readwrite <<EOF bash -xe
uv pip install \
    --constraint /upper-constraints.txt \
        /src/barbican \
        pykmip
EOF

FROM ghcr.io/vexxhost/python-base:2024.2@sha256:7fae28ba6400d1ed505e94eb9288104f8d8cb45fe4fb2b99f1c59d52e6ae1a36
RUN \
    groupadd -g 42424 barbican && \
    useradd -u 42424 -g 42424 -M -d /var/lib/barbican -s /usr/sbin/nologin -c "Barbican User" barbican && \
    mkdir -p /etc/barbican /var/log/barbican /var/lib/barbican /var/cache/barbican && \
    chown -Rv barbican:barbican /etc/barbican /var/log/barbican /var/lib/barbican /var/cache/barbican
COPY --from=build --link /var/lib/openstack /var/lib/openstack
