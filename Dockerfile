# SPDX-FileCopyrightText: © 2025 VEXXHOST, Inc.
# SPDX-License-Identifier: GPL-3.0-or-later
# Atmosphere-Rebuild-Time: 2024-06-25T22:49:25Z

FROM ghcr.io/vexxhost/openstack-venv-builder:2024.2@sha256:7e974cbd1537e2a359e44b6769274a0efd3a1d35ef7bb5cb65dae932a02b62d8 AS build
RUN --mount=type=bind,from=barbican,source=/,target=/src/barbican,readwrite <<EOF bash -xe
uv pip install \
    --constraint /upper-constraints.txt \
        /src/barbican \
        pykmip
EOF

FROM ghcr.io/vexxhost/python-base:2024.2@sha256:2517055abd9dd2c3c36e0aa3933ea9f19497b966f2b0cf8fbf15272ddc8d862c
RUN \
    groupadd -g 42424 barbican && \
    useradd -u 42424 -g 42424 -M -d /var/lib/barbican -s /usr/sbin/nologin -c "Barbican User" barbican && \
    mkdir -p /etc/barbican /var/log/barbican /var/lib/barbican /var/cache/barbican && \
    chown -Rv barbican:barbican /etc/barbican /var/log/barbican /var/lib/barbican /var/cache/barbican
COPY --from=build --link /var/lib/openstack /var/lib/openstack
