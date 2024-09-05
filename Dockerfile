ARG MEMCACHED_VERSION
ARG UNIX_VERSION

FROM memcached:${MEMCACHED_VERSION}-${UNIX_VERSION}

# we're redefining this because Docker labels don't directly support variable substitution
# By redefining the arguments after the `FROM` directive,
# Docker can substitute their values correctly when setting the labels
ARG MEMCACHED_VERSION
ARG UNIX_VERSION

LABEL version="${MEMCACHED_VERSION}-${UNIX_VERSION}"
LABEL description="Memcached ${MEMCACHED_VERSION}-${UNIX_VERSION} with custom SASL authentication"

# Set up the environment variables
ENV SASL_CONF_PATH="/home/memcache/memcached.conf"
ENV MEMCACHED_SASL_PWDB="/home/memcache/memcached-sasl-db"
ENV MEMCACHED_PASSWORD="REPLACE_WITH_SECURE_MEMCACHED_PASSWORD"

# Create entrypoint script
RUN mkdir -p /home/memcache && \
    echo 'mech_list: plain' > "$SASL_CONF_PATH" && \
    echo "zulip@localhost:$MEMCACHED_PASSWORD" > "$MEMCACHED_SASL_PWDB"

# Run memcached with SASL enabled
ENTRYPOINT [ "sh", "-c", "exec memcached -S" ]
