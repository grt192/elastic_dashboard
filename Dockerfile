ARG FLUTTER_VERSION=3.38.6

# ── Stage 1: Flutter base image ──────────────────────────────────────────────
FROM ubuntu:22.04 AS flutter-base

ARG FLUTTER_VERSION

ENV DEBIAN_FRONTEND=noninteractive
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="${FLUTTER_HOME}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin:${PATH}"

RUN apt-get update && apt-get install -y --no-install-recommends \
        curl git unzip xz-utils ca-certificates \
        # Linux desktop build dependencies
        clang cmake ninja-build pkg-config \
        libglu1-mesa libgtk-3-dev liblzma-dev \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch ${FLUTTER_VERSION} \
        https://github.com/flutter/flutter.git ${FLUTTER_HOME} \
    && flutter precache --linux --web \
    && flutter config --no-analytics \
    && flutter doctor -v

# ── Stage 2: Dependencies ─────────────────────────────────────────────────────
FROM flutter-base AS deps

WORKDIR /app

# Copy manifests first for layer caching
COPY pubspec.yaml pubspec.lock ./

RUN flutter pub get

# ── Stage 3: Test ─────────────────────────────────────────────────────────────
FROM deps AS test

COPY . .

# Generate mocks required by tests
RUN dart run build_runner build --delete-conflicting-outputs

RUN flutter test --coverage

# ── Stage 4: Build (Linux release) ────────────────────────────────────────────
FROM deps AS build

COPY . .

RUN dart run flutter_launcher_icons \
    && flutter build linux --release

# ── Stage 5: Minimal runtime image ───────────────────────────────────────────
# Useful for extracting the built bundle via `docker cp` or a bind mount.
FROM ubuntu:22.04 AS release

RUN apt-get update && apt-get install -y --no-install-recommends \
        libgtk-3-0 libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /app/build/linux/x64/release/bundle /opt/elastic-dashboard

WORKDIR /opt/elastic-dashboard

# The app is a GUI application; running it here requires an X11/Wayland
# display forwarded from the host (e.g. -e DISPLAY=$DISPLAY -v /tmp/.X11-unix).
CMD ["/opt/elastic-dashboard/elastic_dashboard"]

FROM deps AS web-build

COPY . .

RUN dart run flutter_launcher_icons \
    && flutter build web --release

FROM nginx:stable-alpine AS web

COPY --from=web-build /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
