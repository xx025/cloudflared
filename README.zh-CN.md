# cloudflared

[English](README.md) | 简体中文

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
