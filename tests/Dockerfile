FROM alpine:latest

ENV HOOKS_DIR=/app/hooks
ENV TESTS_DIR=/app/tests
ENV PATH="$PATH:/app/.bin"

RUN apk add git delta bat tini

RUN git config --global init.defaultBranch main

RUN git config --global user.email "foo@bar.com"
RUN git config --global user.name "Foo Bar"

WORKDIR /app

RUN mkdir .bin

RUN git init

RUN echo -e "hooks\ntests" >.gitignore

RUN git add . && git commit -m "Add .gitignore"
