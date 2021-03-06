FROM ruby:2.6.1

RUN apt-get update && apt-get install -qq -y \
    build-essential git nodejs libpq-dev libgit2-dev pkg-config \
    --fix-missing --no-install-recommends
RUN apt-get install -y --no-install-recommends apt-utils

ENV INSTALL_PATH /myapp

RUN mkdir -p $INSTALL_PATH
RUN mkdir -p $INSTALL_PATH/tmp/pids
WORKDIR /myapp

RUN gem install bundler --no-document
RUN bundle config git.allow_insecure true

COPY Gemfile ./
COPY Gemfile.lock ./
RUN bundle check | bundle install

ENTRYPOINT ["bundle", "exec"]
