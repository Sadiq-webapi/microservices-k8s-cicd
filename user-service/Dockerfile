FROM node:24-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

RUN npm test

RUN npm prune --omit=dev

FROM node:24-alpine

WORKDIR /app

COPY --from=builder /app .

EXPOSE 3000

USER node

CMD ["node", "server.js"]