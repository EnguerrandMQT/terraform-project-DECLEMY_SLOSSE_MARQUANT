FROM python:3.12-slim-bookworm

LABEL org.opencontainers.image.source="https://github.com/fhuitelec/junia-isen-examples-api"

COPY --from=ghcr.io/astral-sh/uv:0.4 /uv /bin/uv

WORKDIR /app
ADD pyproject.toml uv.lock .python-version /app/
RUN uv sync --frozen

ADD examples/examples.py /app/examples/examples.py

EXPOSE 80

ENTRYPOINT ["uv", "run", "newrelic-admin", "run-program"]
CMD ["fastapi", "dev", "examples/examples.py", "--host", "0.0.0.0", "--port", "80"]
