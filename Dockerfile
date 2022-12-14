FROM node:18

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    wget && \
    rm -rf /var/lib/apt/lists/*

ENV SLEEK_VERSION 1.2.1

WORKDIR /app

RUN wget "https://github.com/ransome1/sleek/releases/download/v${SLEEK_VERSION}/sleek-${SLEEK_VERSION}.AppImage"

RUN chmod +x sleek-${SLEEK_VERSION}.AppImage && ./sleek-${SLEEK_VERSION}.AppImage --appimage-extract

RUN npm install --engine-strict asar

ENV PATH /app/node_modules/.bin:$PATH

WORKDIR /app/squashfs-root/resources

RUN asar extract app.asar app/

COPY main.js app/src/main.js

RUN asar pack app/ app.asar && rm app/ -rf

WORKDIR /app

ENV APPIMAGE_VERSION 13

RUN wget "https://github.com/AppImage/AppImageKit/releases/download/${APPIMAGE_VERSION}/appimagetool-x86_64.AppImage"

RUN chmod +x appimagetool-x86_64.AppImage && ./appimagetool-x86_64.AppImage  --appimage-extract-and-run ./squashfs-root

CMD ["ls", "."]
# RUN yarn build:linux
