FROM ruby:2.5.3
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
RUN mkdir /app
WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN gem install byebug -v '10.0.2' --source 'https://rubygems.org/'
RUN bundle install

COPY . .

LABEL maintainer="Sam Stern <sternj@brandeis.edu>"
EXPOSE 3000
CMD puma -C config/puma.rb