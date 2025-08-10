FROM debian:slim

# Install required packages for the script
RUN apt-get update && apt-get install -y \
    bash \
    curl \
    jq \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install supercronic
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.2.34/supercronic-linux-amd64 \
    SUPERCRONIC=supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=e8631edc1775000d119b70fd40339a7238eece14
RUN curl -fsSLO "$SUPERCRONIC_URL" \
    && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
    && chmod +x "$SUPERCRONIC" \
    && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
    && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic

# Set build arguments with defaults for scheduling
ARG START_SCHEDULE="0 8 * * *"
ARG STOP_SCHEDULE="0 18 * * *"

# Copy scripts
COPY railway.sh /usr/local/bin/railway.sh
COPY startup.sh /startup.sh
RUN chmod +x /usr/local/bin/railway.sh /startup.sh

# Create crontab file for supercronic
RUN mkdir -p /app && \
    echo "$START_SCHEDULE /usr/local/bin/railway.sh up" > /app/crontab && \
    echo "$STOP_SCHEDULE /usr/local/bin/railway.sh down" >> /app/crontab

CMD ["/startup.sh"]