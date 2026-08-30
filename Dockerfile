FROM alpine:3.20

ARG TARGETARCH=amd64
ARG CLOUDFLARED_VERSION=latest

RUN apk add --no-cache ca-certificates curl tini \
  && case "$TARGETARCH" in \
    amd64) CLOUDFLARED_ARCH=amd64 ;; \
    arm64) CLOUDFLARED_ARCH=arm64 ;; \
    *) echo "Unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;; \
  esac \
  && if [ "$CLOUDFLARED_VERSION" = "latest" ]; then \
    CLOUDFLARED_URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${CLOUDFLARED_ARCH}"; \
  else \
    CLOUDFLARED_URL="https://github.com/cloudflare/cloudflared/releases/download/${CLOUDFLARED_VERSION}/cloudflared-linux-${CLOUDFLARED_ARCH}"; \
  fi \
  && curl -fsSL "$CLOUDFLARED_URL" -o /usr/local/bin/cloudflared \
  && chmod +x /usr/local/bin/cloudflared \
  && cloudflared --version

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
