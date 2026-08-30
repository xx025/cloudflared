# Back4App Cloudflared Tunnel

Minimal Docker repository for running `cloudflared` on Back4App Containers.

## What this does

This container starts a named Cloudflare Tunnel with a token:

```sh
cloudflared tunnel --no-autoupdate --edge-ip-version 4 --metrics 0.0.0.0:${PORT:-8080} run --token "$TUNNEL_TOKEN"
```

The metrics server listens on Back4App's `PORT` environment variable so the container has an HTTP port for health checks.

## Required Back4App environment variable

Set this in Back4App Containers:

```text
TUNNEL_TOKEN=your_cloudflare_tunnel_token
```

Do not commit the token to Git.

Optional:

```text
TUNNEL_EDGE_IP_VERSION=4
```

This defaults to IPv4 because some container platforms do not provide usable IPv6
egress. You can set it to `auto` or `6` only if the platform has working IPv6.

## Local test

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

## Back4App deploy

1. Push this folder to a GitHub repository.
2. Create a Back4App Container app from that repository.
3. Use `Dockerfile` as the Dockerfile path.
4. Set `TUNNEL_TOKEN` in environment variables.
5. Set the exposed port to `8080`, or let Back4App inject `PORT`.

## Important note for egress

`cloudflared` exposes services behind the container to Cloudflare. It does not by itself turn Cloudflare Workers into a different outbound IP.

For your `codex-oauth-proxy` egress problem, you normally still need a relay service behind the tunnel, for example:

```text
codex-oauth-proxy Worker -> HTTPS relay hostname -> Back4App relay container -> OpenAI
```

This repository only runs the tunnel connector. Add a relay app in the same container or deploy it as a separate Back4App app, then map the tunnel public hostname to that relay's local port.

## IPv6 note

If you see errors like this in Back4App logs:

```text
unable to dial tcp to origin [2606:4700:...]:443: connect: cannot assign requested address
```

the container is being asked to connect to an IPv6 destination but the runtime
does not have a usable IPv6 source address. This image forces the `cloudflared`
edge connection to IPv4 by default. If the log still says
`originService=warp-routing`, then the IPv6 address is the upstream destination
selected by Cloudflare's WARP/VPC path, not the tunnel's Cloudflare edge
connection. In that case the reliable fix is to run an IPv4-only HTTPS relay in
the container and have the Worker call that relay instead of sending the final
ChatGPT/OpenAI hostname through WARP routing directly.
