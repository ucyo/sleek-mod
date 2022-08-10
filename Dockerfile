FROM node:18
RUN apt-get install -y wget

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    wget libfuse2 kmod && \
    rm -rf /var/lib/apt/lists/*

RUN modprobe fuse && groupadd fuse && user="$(whoami)" && usermod -a -G fuse $user

ENV SLEEK_VERSION 1.2.1

WORKDIR /app

RUN wget "https://github.com/ransome1/sleek/releases/download/v${SLEEK_VERSION}/sleek-${SLEEK_VERSION}.AppImage"

RUN chmod +x sleek-${SLEEK_VERSION}.AppImage && ./sleek-${SLEEK_VERSION}.AppImage --appimage-extract

RUN npm install --engine-strict asar

ENV PATH /app/node_modules/.bin:$PATH

WORKDIR /app/squashfs-root/resources

RUN asar extract app.asar app/

COPY todos.mjs app/src/js/todos.mjs

RUN asar pack app/ app.asar && rm app/ -rf

WORKDIR /app

ENV APPIMAGE_VERSION 13

RUN wget "https://github.com/AppImage/AppImageKit/releases/download/${APPIMAGE_VERSION}/appimagetool-x86_64.AppImage"

RUN chmod +x appimagetool-x86_64.AppImage 
# && ./appimagetool-x86_64.AppImage ./squashfs-root

CMD ["asar", "--help"]
# RUN yarn build:linux
