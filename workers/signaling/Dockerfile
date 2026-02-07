FROM node:20-slim

RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g pnpm@9

WORKDIR /app

COPY package.json pnpm-lock.yaml* ./

RUN pnpm install

COPY . .

RUN pnpm run build

EXPOSE 8787

CMD ["sh", "-c", "pnpm run build && pnpm run dev"]
