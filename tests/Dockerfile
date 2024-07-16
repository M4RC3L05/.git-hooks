FROM debian:latest

ENV HOOKS_DIR=/app/hooks
ENV TESTS_DIR=/app/tests
ENV PATH="$PATH:/app/.bin"

RUN apt update && apt install -y git posh colordiff

RUN chsh -s /usr/bin/posh
RUN rm /bin/sh && ln -s /usr/bin/posh /bin/sh

WORKDIR /app

RUN git config --global init.defaultBranch main
RUN git config --global user.email "foo@bar.com"
RUN git config --global user.name "Foo Bar"

RUN mkdir .bin

RUN git init

RUN printf "hooks\ntests\n" >.gitignore

RUN git add . && git commit -m "Add .gitignore"
