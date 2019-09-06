FROM ruby:2.5.3
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
RUN mkdir /app
WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install --binstubs

COPY . .

LABEL maintainer="Sam Stern <sternj@brandeis.edu>"
CMD puma -C config/puma.rb