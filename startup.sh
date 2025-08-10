#!/bin/sh

echo "🚀 Railway Service Cron Starting..."
echo "📍 Timezone: $TZ"
echo "⏰ Cron Schedule:"
cat /var/spool/cron/crontabs/root
echo "🔧 Services: $SERVICES_ID"
echo "📋 Starting cron daemon..."

# Start cron in foreground mode
exec /usr/sbin/crond -f -l 2