FROM python:3.12.5-slim-bullseye

ENV TINI_VERSION=v0.18.0

RUN apt-get update -y && \
    apt-get install -y gcc && \
    pip install -U pip
COPY ./requirements.txt .
RUN pip install -r requirements.txt

COPY . /opt/app/

ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini

RUN chmod +x /tini && \
    useradd --create-home appuser

# STOPSIGNAL SIGINT

USER appuser


WORKDIR /opt/app
ENTRYPOINT ["/tini", "-s", "--"]
EXPOSE 5004

CMD ["gunicorn", "-w 1", "-b :5004", "server:APP"]
