FROM ruby:3.3-alpine

WORKDIR /app

RUN apk add --no-cache build-base

COPY Gemfile ./
RUN bundle install

COPY . .

EXPOSE 5003

CMD ["bundle", "exec", "ruby", "app.rb"]
