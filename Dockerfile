FROM phusion/baseimage:0.10.0
LABEL maintainer="anton.bossenbroek@me.com"


RUN apt-get update --fix-missing  \
      && apt-get install  --no-install-recommends -y python-pip=8.1.1-2ubuntu0.4  \
      python-dev=2.7.12-1~16.04 \
      build-essential=12.1ubuntu2 \
      python-setuptools=20.7.0-1 \
      libssl-dev=1.0.2g-1ubuntu4.10 \
      wget=1.17.1-1ubuntu1.3 \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/*


RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
      && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
      apt-key add - \
      && apt-get update --fix-missing \
      && apt-get install --no-install-recommends -y libpq-dev

RUN mkdir /usr/src/app
WORKDIR /usr/src/app

ADD requirements.txt /usr/src/app
RUN pip install -r requirements.txt

ADD project /usr/src/app

RUN python manage.py migrate
RUN python manage.py loaddata data/congress.json
RUN python manage.py loaddata data/categories.json
RUN python manage.py collectstatic
RUN python manage.py createsuperuser
