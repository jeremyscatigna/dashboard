FROM ruby:2.6.5-alpine3.10

#------------------------------------------------------------------------------
#
# Install Project dependencies
#
#------------------------------------------------------------------------------
RUN apk update -qq && apk add git nodejs postgresql-client ruby-dev build-base \
    libxml2-dev libxslt-dev pcre-dev libffi-dev postgresql-dev tzdata imagemagick

#------------------------------------------------------------------------------
#
# Install required bundler version
#
#------------------------------------------------------------------------------
RUN gem install bundler:2.0.2

#------------------------------------------------------------------------------
#
# Install Yarn
#
#------------------------------------------------------------------------------
ENV PATH=/root/.yarn/bin:$PATH
RUN apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
    yarn

#------------------------------------------------------------------------------
#
# Define working directory
#
#------------------------------------------------------------------------------
RUN mkdir /project
COPY Gemfile Gemfile.lock /project/
WORKDIR /project
RUN bundle install

#------------------------------------------------------------------------------
#
# Copy Package.json and yarn.lock
#
#------------------------------------------------------------------------------
COPY ./package.json ./yarn.lock /project/

#------------------------------------------------------------------------------
#
# Install packages
#
#------------------------------------------------------------------------------
RUN yarn install && yarn check --integrity

# timeout extension required to ensure
# system work properly on first time load
ENV RACK_TIMEOUT_WAIT_TIMEOUT=10000 \
    RACK_TIMEOUT_SERVICE_TIMEOUT=10000 \
    STATEMENT_TIMEOUT=10000

COPY . /project