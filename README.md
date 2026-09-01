# cloudflared

English | [简体中文](README.zh-CN.md)

Minimal Docker image for running `cloudflared` as a Cloudflare Tunnel connector.

This repository is a CloudRouter VPC egress reference implementation. It focuses only on `cloudflared` and can run on any container platform that supports Dockerfile-based deployments and outbound HTTPS access.

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template?template=https%3A%2F%2Fgithub.com%2Fxx025%2Fcloudflared&envs=TUNNEL_TOKEN&TUNNEL_TOKENDesc=Cloudflare+Tunnel+token+used+by+cloudflared)

## Official Documentation

- [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/)
- [Install and run cloudflared](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/)
- [Run cloudflared as a service](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/configure-tunnels/local-management/as-a-service/)
- [Deploy cloudflared replicas](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/deployment-guides/deploy-cloudflared-replicas/)

## What This Does

The container starts a named Cloudflare Tunnel with a token:

```sh
cloudflared tunnel --no-autoupdate --edge-ip-version 4 --metrics 0.0.0.0:${PORT:-8080} run --token "$TUNNEL_TOKEN"
```

The metrics server listens on `PORT` so container platforms have an HTTP endpoint for health checks.

## Required Variables

Set this in your container platform:

```text
TUNNEL_TOKEN=your_cloudflare_tunnel_token
```

Do not commit the token to Git.

Optional:

```text
TUNNEL_EDGE_IP_VERSION=4
```

This defaults to IPv4 because some container platforms do not provide usable IPv6 egress. Set it to `auto` or `6` only if the platform has working IPv6.

## Railway Deploy

Click the Railway button above, then set `TUNNEL_TOKEN`. Railway builds the included `Dockerfile` and exposes `PORT` for the `cloudflared` metrics endpoint.

## Local Test

```sh
export TUNNEL_TOKEN="your_cloudflare_tunnel_token"
docker compose up --build
```

Then check:

```sh
curl http://localhost:8080/metrics
```

Some `cloudflared` versions also expose:

```sh
curl http://localhost:8080/ready
```

## CloudRouter Integration

CloudRouter requires the `NATIVE_EGRESS` Cloudflare VPC Network binding. This connector gives Cloudflare a running tunnel endpoint that can be selected for that binding.

Typical flow:

```text
CloudRouter Worker -> Cloudflare VPC egress binding -> cloudflared connector -> approved upstream HTTPS hosts
```

CloudRouter still enforces its own upstream host allowlist and requires the `NATIVE_EGRESS` binding. Do not replace the binding with ordinary Worker fetch egress.

## IPv6 Note

If you see errors like this in container logs:

```text
unable to dial tcp to origin [2606:4700:...]:443: connect: cannot assign requested address
```

the container is being asked to connect to an IPv6 destination but the runtime does not have a usable IPv6 source address. This image forces the `cloudflared` edge connection to IPv4 by default.
