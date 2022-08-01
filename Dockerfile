FROM python:3.10-slim

WORKDIR /root
COPY pyproject.toml poetry.lock ./
RUN pip install poetry && \
    poetry config virtualenvs.create false && \
    poetry install --no-dev

WORKDIR /app
COPY . /app/

CMD [ "python", "dagger_python_example/main.py" ]
