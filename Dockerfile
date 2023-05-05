FROM ruby:3.2.1

RUN apt-get update -qq \
    && apt-get install -y postgresql-client \
    && apt-get install -y ffmpeg

RUN mkdir /app
RUN mkdir /app/tmp
WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install

COPY . /app

ENV RAILS_ENV=production
ENV RAILS_SERVE_STATIC_FILES=true
ENV RAILS_LOG_TO_STDOUT=true

# ENV POSTGRES_HOST=postgres://$POSTGRES_USERNAME:$POSTGRES_PASSWORD@$POSTGRES_HOST/$POSTGRES_DB__NAME
ENTRYPOINT [ "./entrypoint.sh" ]
EXPOSE 3000

CMD ["bin/rails", "server", "-b", "0.0.0.0"]

HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl --fail http://localhost/ || exit 1
