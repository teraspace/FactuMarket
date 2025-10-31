FROM ruby:3.3-alpine

WORKDIR /app

RUN apk add --no-cache build-base sqlite-dev

COPY Gemfile Gemfile.lock ./
RUN bundle config set force_ruby_platform true \
    && bundle config set build.sqlite3 '--with-sqlite3-dir=/usr' \
    && bundle install

COPY . .

EXPOSE 5002

CMD ["bundle", "exec", "ruby", "interfaces/api.rb"]
