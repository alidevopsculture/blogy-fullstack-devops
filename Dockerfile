FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# stage 2
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=2 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1           

#| Parameter | Value | Meaning |
#|-----------|-------|---------|
#| `--interval` | 30s | Check every 30 seconds |
#| `--timeout` | 3s | Command must complete in 3s |
#| `--start-period` | 5s | Wait 5s before first check |
#| `--retries` | 2 | Try 2 times before marking unhealthy |

#| Part | Meaning |
#|------|---------|
#| `wget` | Download tool (like `curl`) |
#| `--quiet` | Don't show output |
#| `--tries=1` | Only try once |
#| `--spider` | Don't download, just check if exists |
#| `http://localhost/` | Check our homepage |

CMD ["nginx", "-g", "daemon off;"]