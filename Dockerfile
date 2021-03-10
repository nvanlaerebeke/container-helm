FROM alpine/helm:latest
RUN apk add yq --no-cache
ENTRYPOINT [ "sleep", "infinity" ]