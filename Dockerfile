FROM alpine/helm:latest
RUN apk add yq jq --no-cache
COPY chmod +x ./lib/kubectl /bin/kubectl
ENTRYPOINT [ "sleep", "infinity" ]