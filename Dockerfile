FROM alpine/helm:latest

RUN apk add --no-cache yq jq

COPY ./lib/kubectl /bin
COPY ./lib/*.sh /
ENTRYPOINT [ "sleep", "infinity" ]