FROM python:3.13-slim-bookworm

ARG APP_VERSION=local
ENV APP_VERSION=${APP_VERSION} \
    PORT=8000 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

WORKDIR /app
COPY --chown=10001:10001 app/server.py ./server.py
USER 10001:10001

EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import os, urllib.request; urllib.request.urlopen('http://127.0.0.1:' + os.getenv('PORT', '8000') + '/', timeout=2)"

CMD ["python", "server.py"]
