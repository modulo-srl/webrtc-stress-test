FROM node:18-bullseye-slim
RUN apt-get update && apt-get install -y --no-install-recommends git python bash \
    ffmpeg curl xvfb unzip procps xvfb xauth sudo net-tools iproute2 mesa-va-drivers ca-certificates \
    && apt-get clean

#TODO: add specific version of chrome
ENV CHROMIUM_DEB=google-chrome-stable_current_amd64.deb

ENV URL="https://dl.google.com/linux/direct/"

ADD $URL$CHROMIUM_DEB /
RUN apt install -y /$CHROMIUM_DEB \
    && apt-get install -y -f --no-install-recommends \
    && apt-get clean \
    && rm /$CHROMIUM_DEB \
    && rm -rf /var/cache/apt/* \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /app/
#TODO: readd video.mp4
#COPY video.mp4 /app/

# This will build insdie docker image.
# TODO: optimize the image building outside of it
WORKDIR /app
COPY package.json observertc.js entrypoint.sh .eslintrc.js webpack.config.js /app/
COPY scripts /app/scripts/
COPY src /app/src/
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
RUN yarn
RUN yarn lint
RUN yarn add webpack webpack-cli
COPY index.js /app/
RUN yarn webpack --config webpack.config.js

#COPY app.min.js* /app/
ENV DEBUG_LEVEL=WARN
ENTRYPOINT ["/app/entrypoint.sh"]
