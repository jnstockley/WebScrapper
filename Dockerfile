FROM python:3.13.6-slim AS build

COPY requirements.txt .

RUN pip install --upgrade pip && \
    pip install -r requirements.txt && \
    mkdir /web-scrapper

WORKDIR /web-scrapper

COPY  . /web-scrapper/

RUN poetry lock && \
    poetry check && \
    poetry install --without=dev

FROM python:3.13.6-slim

COPY --from=build /usr/local/ /usr/local/

COPY --from=build /root/.cache/pypoetry/virtualenvs  /root/.cache/pypoetry/virtualenvs

COPY --from=build /web-scrapper /web-scrapper

WORKDIR /web-scrapper

ENV PATH="/root/.local/bin:${PATH}"

ENV PYTHONPATH=/web-scrapper:$PYTHONPATH

HEALTHCHECK --interval=60s --timeout=10s --start-period=20s --retries=3 CMD [ "poetry", "run", "python3", "src/healthcheck.py" ]

ENTRYPOINT ["poetry", "run", "python3", "src/webscrapper.py"]
