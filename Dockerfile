FROM alpine:latest

# Install required packages for the script and cron
RUN apk add --no-cache \
    bash \
    curl \
    jq \
    dcron \
    tzdata

# Set build arguments with defaults for scheduling
ARG START_SCHEDULE="0 8 * * *"
ARG STOP_SCHEDULE="0 18 * * *"

# Copy scripts
COPY railway.sh /usr/local/bin/railway.sh
COPY startup.sh /startup.sh
RUN chmod +x /usr/local/bin/railway.sh /startup.sh

# Create crontab for root user
RUN echo "$START_SCHEDULE /usr/local/bin/railway.sh up" > /var/spool/cron/crontabs/root && \
    echo "$STOP_SCHEDULE /usr/local/bin/railway.sh down" >> /var/spool/cron/crontabs/root && \
    chmod 600 /var/spool/cron/crontabs/root

CMD ["/startup.sh"]