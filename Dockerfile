FROM alpine/helm:latest
RUN apk add yq jq --no-cache
ENTRYPOINT [ "sleep", "infinity" ]