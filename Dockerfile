FROM alpine/helm:latest
RUN apk add yq jq curl --no-cache
RUN cd /bin && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
ENTRYPOINT [ "sleep", "infinity" ]