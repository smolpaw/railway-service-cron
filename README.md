# 🕐 Railway Service Cron

A Railway template that automatically starts and stops your Railway services on a schedule using cron jobs. Perfect for development environments, staging servers, or cost optimization by running services only during required hours.

## 🚀 Features

- **⏰ Scheduled Control**: Start and stop Railway services using cron expressions
- **🌍 Timezone Support**: Configure any timezone for your schedules
- **🔧 Flexible Scheduling**: Custom cron expressions or use sensible defaults
- **📊 Smart Management**: Only starts/stops services when needed (checks current status)
- **📝 Railway Dashboard Logs**: All output visible in Railway's log viewer
- **🐳 Alpine-based**: Lightweight Docker container (~15MB memory usage)
- **💾 Low Resource**: Minimal memory footprint - uses only ~15MB RAM

## 📋 Requirements

- **Railway Account Token**: Personal or Team token (not Project token)
- **Service IDs**: Comma-separated list of Railway service IDs to manage
- **Railway Project**: This service must be deployed in the same project as the services you want to manage

## 🎯 Quick Deploy

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/your-template-id)

### Required Configuration

When deploying, you'll need to provide:

| Variable                | Description                                          | Required                                  |
| ----------------------- | ---------------------------------------------------- | ----------------------------------------- |
| `RAILWAY_ACCOUNT_TOKEN` | Your Railway personal/team API token                 | ✅                                        |
| `SERVICES_ID`           | Comma-separated Railway service IDs                  | ✅                                        |
| `TZ`                    | Timezone (e.g., `America/New_York`, `Europe/London`) | ❌ (defaults to `UTC`)                     |
| `START_SCHEDULE`        | Cron expression for starting services                | ❌ (defaults to `0 8 * * *` - 8 AM daily)  |
| `STOP_SCHEDULE`         | Cron expression for stopping services                | ❌ (defaults to `0 18 * * *` - 6 PM daily) |

## 🔧 Configuration Examples

### Default Schedule (8 AM - 6 PM UTC daily)

```bash
RAILWAY_ACCOUNT_TOKEN=a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6
SERVICES_ID=service-id-1,service-id-2,service-id-3
```

### Custom Schedule (9 AM - 5 PM EST, weekdays only)

```bash
RAILWAY_ACCOUNT_TOKEN=a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6
SERVICES_ID=service-id-1,service-id-2
TZ=America/New_York
START_SCHEDULE="0 9 * * 1-5"
STOP_SCHEDULE="0 17 * * 1-5"
```

### Weekend Schedule (10 AM - 2 PM, weekends only)

```bash
RAILWAY_ACCOUNT_TOKEN=a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6
SERVICES_ID=service-id-1
TZ=Europe/London
START_SCHEDULE="0 10 * * 6,0"
STOP_SCHEDULE="0 14 * * 6,0"
```

## 🔑 Getting Your Railway Token

1. Go to [Railway Dashboard → Account Settings → Tokens](https://railway.app/account/tokens)
2. Click **"Create Token"**
3. Choose **"Personal Account Token"** (not Team or Project token)
4. Give it a name (e.g., "Service Cron Manager")
5. Copy the generated token (random string of characters)

## 🆔 Getting Service IDs

1. Go to your Railway project
2. Click on each service you want to manage
3. Copy the service ID from the URL or service settings
4. Combine them with commas: `service-1-id,service-2-id,service-3-id`

## 📅 Cron Expression Reference

| Expression     | Description          |
| -------------- | -------------------- |
| `0 8 * * *`    | Daily at 8:00 AM     |
| `0 18 * * *`   | Daily at 6:00 PM     |
| `0 9 * * 1-5`  | Weekdays at 9:00 AM  |
| `0 17 * * 1-5` | Weekdays at 5:00 PM  |
| `0 10 * * 6,0` | Weekends at 10:00 AM |
| `*/30 * * * *` | Every 30 minutes     |

## 📊 Monitoring

- **Railway Dashboard**: View all cron job logs in Railway's log viewer
- **Status Messages**: Clear output showing what actions were taken
- **Smart Skipping**: Won't try to start already running services or stop already stopped services

## 🔍 Troubleshooting

### Service Not Starting/Stopping
- Verify your `RAILWAY_ACCOUNT_TOKEN` has proper permissions
- Ensure `SERVICES_ID` contains valid Railway service IDs
- Check that services exist in the same project

### Cron Not Running
- Verify cron expressions using [crontab.guru](https://crontab.guru)
- Check timezone settings if schedules seem off
- Review Railway logs for any error messages

### Permission Issues
- Use **Personal Account Token**, not Project or Team token
- Ensure the token has access to the project containing the services

## 🏗️ How It Works

1. **Container starts** and validates configuration
2. **Cron daemon** runs in the background with your schedules
3. **Start schedule** runs the script with `up` command
4. **Stop schedule** runs the script with `down` command
5. **Script checks** current service status before taking action
6. **All output** is logged to Railway dashboard for monitoring

## 📄 License

MIT License - feel free to modify and use for your projects!

## 🤝 Contributing

Found a bug or want to add a feature? PRs welcome!

---

**⚡ Save money on Railway by only running services when you need them!**