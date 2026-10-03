FROM node:24.21.0-alpine
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev --ignore-scripts --no-audit --no-fund
COPY index.js ./
EXPOSE 3000
CMD ["node", "index.js"]
