# Construido sobre: https://about.gitlab.com/blog/2018/10/24/setting-up-gitlab-ci-for-android-projects/
FROM node:22-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y default-jdk chromium unzip wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/default-java

USER node
WORKDIR /home/node

RUN mkdir -p /home/node/.npm-global/bin
ENV PATH=/home/node/.npm-global/bin:$PATH
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global

RUN mkdir -p /home/node/tools && mkdir -p /home/node/tools/emulator
WORKDIR /home/node/tools
ENV ANDROID_HOME=/home/node/tools

RUN npm i -g appium

ENV ANDROID_SDK_ROOT=$ANDROID_HOME
ENV PATH=${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/emulator

# comes from https://developer.android.com/studio/#command-tools
ENV ANDROID_SDK_TOOLS_VERSION=10406996

RUN wget -q https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS_VERSION}_latest.zip -O android-sdk-tools.zip \
    && mkdir -p ${ANDROID_HOME}/cmdline-tools/ \
    && unzip -q android-sdk-tools.zip -d ${ANDROID_HOME}/cmdline-tools/ \
    && mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest \
    && chmod -R 755 /home/node/tools \
    && rm android-sdk-tools.zip \
    && yes | sdkmanager --licenses \
    && wget -O ${ANDROID_HOME}/emulator/android-wait-for-emulator https://raw.githubusercontent.com/travis-ci/travis-cookbooks/master/community-cookbooks/android-sdk/files/default/android-wait-for-emulator \
    && chmod +x ${ANDROID_HOME}/emulator/android-wait-for-emulator \
    && sdkmanager platform-tools

# emulator is not available on linux/arm64 (https://issuetracker.google.com/issues/227219818)
RUN if [ $(uname -m) == "x86_64" ]; then sdkmanager emulator ; fi

RUN mkdir -p /home/node/tests
WORKDIR /home/node/tests
RUN mkdir -p reports
COPY --chown=node:node package*.json mobile.json properties.json ./
RUN npm ci --omit=dev || npm install --omit=dev

# Chorme headless (También aplica en chromium)
# https://github.com/GoogleChrome/chrome-launcher/commit/4771eafff2b5a93c8cad3c359d027253618b936b
ENV HEADLESS=true

# Esta capa debe ir de ultimas para que no se necesite recostruir todo el docker para probar un cambio
COPY --chown=node:node features features

ENTRYPOINT ["npm", "test"]