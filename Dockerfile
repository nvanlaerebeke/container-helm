FROM alpine/helm:latest
RUN apk add yq jq --no-cache
COPY --chmod=+x ./lib/kubectl /bin/
ENTRYPOINT [ "sleep", "infinity" ]