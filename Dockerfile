FROM ubuntu:22.04

RUN apt-get update --fix-missing && \
    apt-get -y upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq libpq-dev gcc python3.10 python3-pip && \
    apt-get clean

WORKDIR /sample-app

COPY . /sample-app/

# Install requirements
RUN pip3 install -r requirements.txt

# Install optional server requirements if the file exists
RUN if [ -f requirements-server.txt ]; then pip3 install -r requirements-server.txt; fi

# Install coverage (no-cache)
RUN pip3 install --no-cache-dir coverage

ENV LC_ALL="C.UTF-8"
ENV LANG="C.UTF-8"

EXPOSE 8000/tcp

CMD ["/bin/sh", "-c", "flask db upgrade && python -c 'import psycopg2; conn = psycopg2.connect(\"dbname=sampledb user=postgres password=password host=db port=5432\"); print(\"Connection Successful\");' && gunicorn app:app -b 0.0.0.0:8000"]
