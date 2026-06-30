# ── Stage 1: Builder ──────────────────────────────────────────────
FROM python:3.11.13-slim-bookworm@sha256:86adf8dbadc3d6e82ee5dd2c74bec2e1c2467cdad47886280501df722372d2e1 AS builder

WORKDIR /build

# Create isolated virtual environment
RUN python -m venv /opt/venv

# Use it
ENV PATH="/opt/venv/bin:$PATH"

# Install build dependencies
COPY requirements.txt .
RUN python -m pip install --upgrade pip
RUN pip install \
    --no-cache-dir \
    --disable-pip-version-check \
    -r requirements.txt

# ── Stage 2: Runtime ──────────────────────────────────────────────
FROM python:3.11.13-slim-bookworm@sha256:86adf8dbadc3d6e82ee5dd2c74bec2e1c2467cdad47886280501df722372d2e1 AS runtime

# Install curl for health check
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends curl \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy installed packages from builder
COPY --from=builder /opt/venv /opt/venv

# Copy application
COPY app/ .

# Non-root user
RUN useradd \
    --uid 10001 \
    --create-home \
    --shell /usr/sbin/nologin \
    appuser \
    && chown -R appuser:appuser /app

USER appuser

ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8080

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

LABEL maintainer="Abou"
LABEL application="Weather Platform"
LABEL description="Flask Weather API"

CMD ["python", "app.py"]
