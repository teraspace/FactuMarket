FROM ruby:3.3-alpine

WORKDIR /app

RUN apk add --no-cache build-base sqlite-dev

COPY Gemfile ./
RUN bundle install

COPY . .

EXPOSE 5002

CMD ["bundle", "exec", "ruby", "interfaces/api.rb"]
