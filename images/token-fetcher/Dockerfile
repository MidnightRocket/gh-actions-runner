FROM docker.io/debian:stable-slim

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
	--mount=type=cache,target=/var/lib/apt,sharing=locked \
	export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
	&& apt-get update \
	&& apt-get install --no-install-recommends -qqy \
		ca-certificates \
		curl

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
	--mount=type=cache,target=/var/lib/apt,sharing=locked \
	export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
	&& install -m 0755 -d /etc/apt/keyrings \
	&& curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
	&& chmod a+r /etc/apt/keyrings/docker.asc \
	&& echo \
		"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
		$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
		tee /etc/apt/sources.list.d/docker.list > /dev/null \
	&& apt-get update \
	&& apt-get install --no-install-recommends -qqy \
		# docker-ce \
		docker-ce-cli \
		# containerd.io \
		# docker-buildx-plugin \
		docker-compose-plugin

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
	--mount=type=cache,target=/var/lib/apt,sharing=locked \
	export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
	&& apt-get update \
	&& apt-get install --no-install-recommends -qqy \
		ncat \
		jq

COPY "./server.sh" "/tokenfetcher/server.sh"
COPY "./gettoken.sh" "/tokenfetcher/gettoken.sh"
COPY "./clean-docker.sh" "/tokenfetcher/clean-docker.sh"

VOLUME ["/token-endpoint", "/tmp/token-cache"]
ENTRYPOINT ["/tokenfetcher/server.sh"]
