FROM alpine:latest

ENV TESTS_DIR=/app/tests
ENV PATH="$PATH:/app/.bin"

RUN apk add --no-cache git dash colordiff

RUN rm /bin/sh && ln -s /usr/bin/dash /bin/sh

WORKDIR /app

RUN git config --global init.defaultBranch main
RUN git config --global user.email "foo@bar.com"
RUN git config --global user.name "Foo Bar"

RUN mkdir .bin

RUN git init
RUN git config --local core.hooksPath "/app/hooks"

RUN printf "hooks\ntests\n.bin\n" >.gitignore

RUN git add . && git commit -m "Add .gitignore"
