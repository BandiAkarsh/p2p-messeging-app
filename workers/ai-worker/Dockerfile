FROM node:20-alpine

RUN npm install -g pnpm@9 wrangler@^3.107.3

WORKDIR /app

COPY package.json pnpm-lock.yaml* ./

RUN pnpm install

COPY . .

RUN pnpm run build

EXPOSE 8788

CMD ["pnpm", "run", "dev"]
