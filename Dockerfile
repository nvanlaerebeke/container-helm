FROM alpine/helm:latest
RUN apk add yq jq --no-cache
COPY ./lib/*.sh /
ENTRYPOINT [ "sleep", "infinity" ]