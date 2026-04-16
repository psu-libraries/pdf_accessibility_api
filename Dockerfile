FROM harbor.k8s.libraries.psu.edu/library/ruby-3.4.9-node-22:20260415 AS base
ARG UID=3000

USER root
RUN apt-get update && \
  apt-get install --no-install-recommends -y \
  libmariadb-dev \
  libyaml-dev \
  mariadb-client && \
  rm -rf /var/lib/apt/lists*


RUN useradd -u $UID app -d /app
WORKDIR /app
RUN chown app:app /app
RUN mkdir /app/tmp
RUN mkdir /tmp/app/
RUN chown app:app /tmp/app && chmod 755 /tmp/app
COPY --chown=app:app Gemfile Gemfile.lock /app/
COPY --chown=app:app . .

USER app

# in the event that bundler runs outside of docker, we get in sync with it's bundler version
RUN gem install bundler -v "$(grep -A 1 \"BUNDLED WITH\" Gemfile.lock | tail -n 1)"
RUN bundle config set path 'vendor/bundle'
RUN bundle config set bin '.bundle/bin'
ENV PATH="/app/.bundle/bin:$PATH"
RUN bundle install && \
  rm -rf /app/.bundle/cache && \
  rm -rf /app/vendor/bundle/ruby/*/cache

COPY --chown=app:app package.json yarn.lock /app/
RUN yarn install --frozen-lockfile && \
  rm -rf /app/.cache && \
  rm -rf /app/tmp

COPY --chown=app:app . /app
RUN mkdir -p tmp/uploads && chown -R app:app tmp/uploads

# Ensure uploads and tmp are owned by app user (if needed)
USER root
RUN chown -R app:app /app/tmp /app/tmp/uploads || true
USER app

FROM base AS dev-worker

ENTRYPOINT ["entrypoints/dev-worker.sh"]

FROM base AS dev-mock-remediation-tool

ENTRYPOINT ["entrypoints/dev-mock-remediation-tool.sh"]

FROM base AS dev

USER root

RUN apt-get update && apt-get install -y rsync wget

USER app
RUN bundle config set path 'vendor/bundle'

CMD ["bin/startup"]

# Final Target
FROM base AS production

# Clean up Bundle (Bundler 4 syntax)
RUN bundle config set without 'development test' && \
  bundle install && \
  bundle clean && \
  rm -rf /app/.bundle/cache && \
  rm -rf /app/vendor/bundle/ruby/*/cache

RUN RAILS_ENV=production \
  NODE_ENV=production \
  DEFAULT_URL_HOST=localhost \
  SECRET_KEY_BASE=rails_bogus_key \
  AWS_BUCKET=bucket \
  AWS_ACCESS_KEY_ID=key \
  AWS_SECRET_ACCESS_KEY=secret \
  AWS_REGION=us-east-1 \
  LLM_MODEL=default \
  bundle exec rails assets:precompile && \
  rm -rf /app/.cache/ && \
  rm -rf /app/node_modules/.cache/ && \
  rm -rf /app/tmp/ && \
  mkdir /app/tmp && chown -R app:app /app/tmp

CMD ["bin/startup"]
