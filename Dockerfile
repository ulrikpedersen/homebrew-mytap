FROM homebrew/brew
ARG BUILD_DATE

# Labelling after some form of schema: http://label-schema.org/rc1/
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.maintainer="Ulrik Kofoed Pedersen"
LABEL org.label-schema.name="brew-mytap"
LABEL org.label-schema.description="A homebrew/brew based container for test and development of ulrikkofoed/mytap formulae"
LABEL org.label-schema.url="https://github.com/ulrikpedersen/homebrew-mytap"
LABEL org.label-schema.vcs-url="https://github.com/ulrikpedersen/homebrew-mytap"

USER linuxbrew
ENV PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH
WORKDIR /home/linuxbrew

RUN brew tap ulrikpedersen/mytap
RUN brew tap homebrew/test-bot
RUN brew update
RUN brew install epics-base
