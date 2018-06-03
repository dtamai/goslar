FROM ruby:2.5-alpine

RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./

RUN apk --update add \
        build-base \
        libxml2-dev \
        libxslt-dev \
        postgresql-dev && \
    bundle install && \
    apk del build-base

COPY . .
