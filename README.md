# cloudflared

English | [简体中文](#简体中文)

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

## 简体中文

这是一个用于运行 `cloudflared` 的最小 Docker 镜像，可作为 Cloudflare Tunnel connector 使用。

本仓库是 CloudRouter VPC 出口的一种参考实现，只关注 `cloudflared`，适合部署到任何支持 Dockerfile 和出站 HTTPS 的容器平台。

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template?template=https%3A%2F%2Fgithub.com%2Fxx025%2Fcloudflared&envs=TUNNEL_TOKEN&TUNNEL_TOKENDesc=Cloudflare+Tunnel+token+used+by+cloudflared)

## 官方文档

- [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/)
- [安装和运行 cloudflared](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/)
- [以服务方式运行 cloudflared](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/configure-tunnels/local-management/as-a-service/)
- [部署 cloudflared 副本](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/deployment-guides/deploy-cloudflared-replicas/)

## 作用

容器会使用 token 启动一个已命名的 Cloudflare Tunnel：

```sh
cloudflared tunnel --no-autoupdate --edge-ip-version 4 --metrics 0.0.0.0:${PORT:-8080} run --token "$TUNNEL_TOKEN"
```

metrics 服务监听 `PORT`，方便 Railway 等容器平台进行健康检查。

## 必需变量

在容器平台中设置：

```text
TUNNEL_TOKEN=your_cloudflare_tunnel_token
```

不要把 token 提交到 Git。

可选：

```text
TUNNEL_EDGE_IP_VERSION=4
```

默认使用 IPv4，因为一些容器平台没有可用的 IPv6 出口。只有在平台确认支持 IPv6 时，才建议设置为 `auto` 或 `6`。

## Railway 快速部署

点击上方 Railway 按钮，然后填写 `TUNNEL_TOKEN`。Railway 会构建仓库内的 `Dockerfile`，并通过 `PORT` 暴露 `cloudflared` metrics 端点。

## 本地测试

```sh
export TUNNEL_TOKEN="your_cloudflare_tunnel_token"
docker compose up --build
```

检查：

```sh
curl http://localhost:8080/metrics
```

部分 `cloudflared` 版本也会暴露：

```sh
curl http://localhost:8080/ready
```

## CloudRouter 集成

CloudRouter 要求使用 `NATIVE_EGRESS` Cloudflare VPC Network binding。这个 connector 可以作为该 binding 可选择的 tunnel endpoint。

典型链路：

```text
CloudRouter Worker -> Cloudflare VPC egress binding -> cloudflared connector -> approved upstream HTTPS hosts
```

CloudRouter 仍会执行自己的上游 host allowlist，并要求 `NATIVE_EGRESS` binding。不要用普通 Worker fetch egress 替代这个 binding。

## IPv6 说明

如果容器日志出现：

```text
unable to dial tcp to origin [2606:4700:...]:443: connect: cannot assign requested address
```

说明容器运行时可能没有可用的 IPv6 源地址。本镜像默认强制 `cloudflared` 使用 IPv4 连接 Cloudflare edge。
