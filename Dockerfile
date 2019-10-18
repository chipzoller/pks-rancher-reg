FROM alpine:3.10
RUN addgroup -g 1001 -S appuser && adduser -u 1001 -S appuser -G appuser
ADD pks-rancher-reg.sh /
RUN set -x apk update && apk add --no-cache curl ca-certificates jq
RUN /usr/bin/curl -sLO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl && chmod +x /kubectl
RUN chown appuser:appuser /pks-rancher-reg.sh && chmod +x /pks-rancher-reg.sh
USER appuser
ENTRYPOINT ["/pks-rancher-reg.sh"]
