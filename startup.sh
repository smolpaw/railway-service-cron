#!/bin/sh

echo "🚀 Railway Service Cron Starting..."
echo "📍 Timezone: $TZ"
echo "⏰ Cron Schedule:"
cat /app/crontab
echo "🔧 Services: $SERVICES_ID"
echo "📋 Starting supercronic..."

# Start supercronic with crontab file
exec /usr/local/bin/supercronic /app/crontab