FROM debian:stretch
LABEL maintainer="https://github.com/niess"

# Image meta data
ARG REPO_URL="https://github.com/niess/docker-geant4"
ARG BUILD_DATE
ARG VCS_REF
LABEL org.label-schema.build-date=$BUILD_DATE                                  \
      org.label-schema.url="$REPO_URL/commit/$VCS_REF"                         \
      org.label-schema.vcs-ref=$VCS_REF                                        \
      org.label-schema.version=1.0

# Get a build chain for Geant4 and some extra dependencies
RUN apt update -y -qq                                                       && \
    apt install --no-install-recommends -qq -y                                 \
        ca-certificates git cmake g++ ninja-build libxerces-c-dev           && \
    apt autoremove -y -qq                                                   && \
    apt clean -y -qq                                                        && \
    rm -rf /var/lib/apt/lists/*

# Fetch the Geant4 source, build, install and clean
ARG DOCKER_TAG
WORKDIR /tmp
RUN git clone https://gitlab.cern.ch/geant4/geant4.git                      && \
    cd geant4                                                               && \
    git checkout $DOCKER_TAG                                                && \
    mkdir ../geant4-build                                                   && \
    cd ../geant4-build                                                      && \
    cmake -GNinja                                                              \
          -DCMAKE_BUILD_TYPE=Release                                           \
          -DCMAKE_INSTALL_PREFIX=/usr/local/geant4                             \
          -DGEANT4_INSTALL_DATA=ON                                             \
          -DGEANT4_USE_SYSTEM_EXPAT=OFF                                        \
          -DGEANT4_USE_GDML=ON                                                 \
          ../geant4                                                         && \
    ninja                                                                   && \
    ninja install                                                           && \
    cd ..                                                                   && \
    rm -rf geant4 geant4-build /usr/local/geant4/share/Geant4-*/examples

# Set the entry point
COPY entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD [ "/bin/bash" ]
