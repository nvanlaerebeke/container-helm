FROM alpine/helm:latest

RUN apk add --no-cache \
	yq \
	jq \
        # .NET Core dependencies
        krb5-libs \
        libgcc \
        libintl \
        libssl1.1 \
        libstdc++ \
        zlib

ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true

COPY ./lib/kubectl /bin
COPY ./lib/*.sh /
COPY ./lib/version /bin/version
ENTRYPOINT [ "sleep", "infinity" ]
