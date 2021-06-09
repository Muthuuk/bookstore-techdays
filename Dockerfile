# The version number tag for the base container
ARG FROM_VERSION=11.0.10-jre-slim-buster
FROM openjdk:${FROM_VERSION}

ARG REPOSITORY_NAME=octodemo/template-bookstore-v2
ARG VERSION=0.0.0-SNAPSHOT
ARG revision=unknown
ARG repo_url=http://github.com/${REPOSITORY_NAME}

# Default the server port if not specified
ARG SERVER_PORT
ENV SERVER_PORT=${SERVER_PORT:-8080}
EXPOSE ${SERVER_PORT}

ARG install_dir=/opt/app
ARG username=github

# Create a user and directory to install and run the application
RUN useradd -m -d ${install_dir} -u 1000 ${username}
USER ${username}
WORKDIR ${install_dir}

# Copy the self contained jar file to the container
COPY target/bookstore-v2-${VERSION}.jar bookstore.jar

ENTRYPOINT ["/usr/local/openjdk-11/bin/java", "-jar", "bookstore.jar"]

LABEL org.opencontainers.image.authors="GitHub Solutions Engineering" \
    org.opencontainers.image.url="${repo_url}" \
    org.opencontainers.image.documentation="${repo_url}/README.md" \
    org.opencontainers.image.source="${repo_url}" \
    org.opencontainers.image.version="${VERSION}" \
    org.opencontainers.image.revision="${revision}" \
    org.opencontainers.image.vendor="GitHub" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.title="GitHub Solutions Engineering Java Bookstore" \
    org.opencontainers.image.description="GitHub Demo Bookstore written in Java"