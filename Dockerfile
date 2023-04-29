FROM ruby:3.2.1

RUN apt-get update -qq \
    && apt-get install -y postgresql-client

RUN mkdir /myapp
RUN mkdir /myapp/tmp
WORKDIR /myapp

COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install

COPY . /myapp

ENV RAILS_ENV=production
ENV RAILS_SERVE_STATIC_FILES=true
ENV RAILS_LOG_TO_STDOUT=true
ENV DATABASE_URL=postgres://SkyNet:$SKYNET_DATABASE_PASSWORD@db:5432/SkyNet_production
ENV OPENAI_TOKEN=''
ENV TELEGRAM_BOT_TOKEN=''
ENV RAILS_MASTER_KEY=''

EXPOSE 3000

CMD ["bin/rails", "server", "-b", "0.0.0.0"]

HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl --fail https://localhost/ || exit 1
