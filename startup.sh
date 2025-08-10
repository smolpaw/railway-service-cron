#!/bin/sh

echo "🚀 Railway Service Cron Starting..."
echo "📍 Timezone: $TZ"
echo "⏰ Start Schedule: $START_SCHEDULE"  
echo "🛑 Stop Schedule: $STOP_SCHEDULE"
echo "🔧 Services: $SERVICES_ID"
echo "📋 Starting cron supervisor..."

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf