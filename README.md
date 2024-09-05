# Memcached with SASL Authentication

[![Build Docker images](https://github.com/engineervix/docker-memcached-sasl/actions/workflows/build-docker-image.yml/badge.svg)](https://github.com/engineervix/docker-memcached-sasl/actions/workflows/build-docker-image.yml)
[![Publish Docker images](https://github.com/engineervix/docker-memcached-sasl/actions/workflows/publish-docker-image.yml/badge.svg)](https://github.com/engineervix/docker-memcached-sasl/actions/workflows/publish-docker-image.yml)


This is a custom Docker image for Memcached (based on [this docker compose setup in the Zulip docs](https://github.com/zulip/docker-zulip/blob/6a75497a17e4ed727fb011f39f84cd64ac9ea36f/docker-compose.yml#L18C1-L25C26)), preconfigured to support SASL authentication using plain-text authentication. It automatically sets up the SASL configuration and password database at runtime.

I created it because I was trying to self-host Zulip via [Dokku](https://dokku.com/), and couldn't find a decent way to configure Memcached as in the above setup, using the [Official memcached plugin for dokku](https://github.com/dokku/dokku-memcached).

## Features

- Memcached version `1.6.29-alpine`
- SASL authentication enabled
- Custom environment variables for SASL configuration
- Automatically generates the SASL configuration file and user password database

## Usage

### Build the Image

1. Clone the repository to your local machine:

   ```bash
   git clone https://github.com/your-repo/memcached-sasl.git
   cd memcached-sasl
    ```

2. Build the Docker image:

    ```bash
    docker build -t your-dockerhub-username/memcached-sasl .
    ```

3. Push the image to Docker Hub (or another container registry):

    ```bash
    docker push your-dockerhub-username/memcached-sasl
    ```

### Environment Variables

The following environment variables can be configured when running the container:

-   **`SASL_CONF_PATH`**: Path to the SASL configuration file (default: `/home/memcache/memcached.conf`).
-   **`MEMCACHED_SASL_PWDB`**: Path to the SASL password database (default: `/home/memcache/memcached-sasl-db`).
-   **`MEMCACHED_PASSWORD`**: Password used for the `zulip` user (default: `"REPLACE_WITH_SECURE_MEMCACHED_PASSWORD"`).

### How It Works

1.  The entrypoint script creates the SASL configuration file at the location specified by `SASL_CONF_PATH`. This file enables the plain-text mechanism for SASL authentication.

2.  The script generates a password database file (`MEMCACHED_SASL_PWDB`), containing credentials for the user `zulip`. The username is set as `zulip@localhost` with the password defined by `MEMCACHED_PASSWORD`.

3.  The `memcached -S` command starts Memcached with SASL authentication enabled, enforcing user authentication for all clients.

### Running the Image

You can run the image directly using Docker:

```bash
docker run -d \
  -e MEMCACHED_PASSWORD=your_secure_password \
  your-dockerhub-username/memcached-sasl
```

Or, use this image in a Dokku setup:

```bash
sudo dokku memcached:create memcached-zulip \
  --image "your-dockerhub-username/memcached-sasl" \
  --image-version "latest" \
  --custom-env "MEMCACHED_PASSWORD=your_secure_password"
```

### Customization

-   If you want to customize the SASL mechanism or add more users, you can modify the `Dockerfile` or adjust the entrypoint script.
-   For a more secure setup, ensure that the `MEMCACHED_PASSWORD` environment variable is set to a strong, random value.

---