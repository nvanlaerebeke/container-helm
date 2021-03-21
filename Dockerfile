FROM alpine/helm:latest
RUN apk add yq jq --no-cache
COPY ./lib/kubectl /bin
COPY ./lib/*.sh /
ENTRYPOINT [ "sleep", "infinity" ]
