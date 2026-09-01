# CloudRouter VPC Egress Connector

Minimal Docker image for running `cloudflared` as a Cloudflare Tunnel connector.

This repository is a reference implementation for the VPC egress side of CloudRouter deployments. It is intentionally small so it can run on any container platform that supports Dockerfile-based deployments and outbound HTTPS access.

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template?template=https%3A%2F%2Fgithub.com%2Fxx025%2Fcloud-router-vpc-egress&envs=TUNNEL_TOKEN&TUNNEL_TOKENDesc=Cloudflare+Tunnel+token+used+by+cloudflared)

## What This Does

The container starts a named Cloudflare Tunnel with a token:

```sh
cloudflared tunnel --no-autoupdate --edge-ip-version 4 --metrics 0.0.0.0:${PORT:-8080} run --token "$TUNNEL_TOKEN"
```

The metrics server listens on `PORT` so container platforms have an HTTP endpoint for health checks.

## Required Environment Variable

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

## Deploy

1. Create a Cloudflare Tunnel for CloudRouter egress.
2. Copy the tunnel token into your container platform as `TUNNEL_TOKEN`.
3. Deploy this repository with the included `Dockerfile`.
4. Set the exposed HTTP port to `8080`, or let the platform inject `PORT`.
5. Use the Tunnel/VPC egress ID as CloudRouter's `CLOUDFLARE_TUNNEL_ID` build variable.

## Railway Deploy

Click the Railway button above, then set:

```text
TUNNEL_TOKEN=your_cloudflare_tunnel_token
```

Railway will build the included `Dockerfile`. The container exposes `PORT` for the `cloudflared` metrics endpoint, which is enough for Railway health checks.

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

If the log still says `originService=warp-routing`, then the IPv6 address is the upstream destination selected by Cloudflare's WARP/VPC path, not the tunnel's Cloudflare edge connection. In that case, use an IPv4-capable runtime or place an IPv4-only HTTPS relay behind the tunnel.
