FROM ruby:2.3.1-alpine

RUN apk update && apk add g++ musl-dev make

ADD ./ /src
WORKDIR /src

RUN gem install bundler && bundle install
EXPOSE 80
LABEL APP_NAME="dontdredgetheriver"
ENTRYPOINT ["ruby", "app.rb", "-p", "80", "-o", "0.0.0.0"]
