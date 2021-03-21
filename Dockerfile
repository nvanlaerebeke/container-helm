FROM alpine/helm:latest
RUN apk add yq jq --no-cache
COPY ./lib/kubectl /bin/kubectl
ENTRYPOINT [ "sleep", "infinity" ]