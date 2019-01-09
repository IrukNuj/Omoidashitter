FROM ruby:2.6.0
# Docker上に作業ファイルを作成
RUN mkdir /omoidashitter
ENV APP_ROOT /omoidashitter
WORKDIR $APP_ROOT
RUN apt-get update -qq && \
    apt-get install -y nodejs \
                       mysql-client \
                       --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*
    # -qq : エラー以外表示しない

# プロジェクト上のGemfileをdocker上にコピー
COPY Gemfile $APP_ROOT
COPY Gemfile.lock $APP_ROOT
RUN \
    echo 'gem: --no-document' >> ~/.gemrc && \
    cp ~/.gemrc /etc/gemrc && \
    chmod uog+r /etc/gemrc && \
    bundle config --global build.nokogiri --use-system-libraries && \
    bundle config --global jobs 4 && \
    bundle install && \
    rm -rf ~/.gem
COPY . $APP_ROOT