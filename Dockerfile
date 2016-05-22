FROM ruby:2.2.3

ADD ./ /src
WORKDIR /src

RUN gem install bundler && bundle install
EXPOSE 80
ENTRYPOINT ["ruby", "app.rb", "-p", "80", "-o", "0.0.0.0"]
