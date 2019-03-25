FROM debian:stretch
LABEL maintainer="https://github.com/niess"

# Image meta data
ARG ARCHIVE_URL="http://cern.ch/geant4-data/releases"
ARG BUILD_DATE
ARG DOCKER_TAG
LABEL org.label-schema.build-date=$BUILD_DATE                                  \
      org.label-schema.url="$ARCHIVE_URL/geant4.$DOCKER_TAG.tar.gz"            \
      org.label-schema.version=$DOCKER_TAG

# Get a build chain for Geant4 and some extra dependencies
RUN apt update -y -qq                                                       && \
    apt install --no-install-recommends -qq -y                                 \
        wget cmake g++ ninja-build libxerces-c-dev                          && \
    apt autoremove -y -qq                                                   && \
    apt clean -y -qq                                                        && \
    rm -rf /var/lib/apt/lists/*

# Fetch the Geant4 source, build, install and clean
WORKDIR /tmp
RUN wget -q "$ARCHIVE_URL/geant4.$DOCKER_TAG.tar.gz"                        && \
    tar -xzf "geant4.$DOCKER_TAG.tar.gz"                                    && \
    mv "geant4.$DOCKER_TAG" geant4                                          && \
    mkdir geant4-build                                                      && \
    cd geant4-build                                                         && \
    cmake -GNinja                                                              \
          -DCMAKE_BUILD_TYPE=Release                                           \
          -DCMAKE_INSTALL_PREFIX=/usr/local/geant4                             \
          -DGEANT4_INSTALL_DATA=ON                                             \
          -DGEANT4_USE_SYSTEM_CLHEP=OFF                                        \
          -DGEANT4_USE_SYSTEM_EXPAT=OFF                                        \
          -DGEANT4_USE_GDML=ON                                                 \
          ../geant4                                                         && \
    ninja                                                                   && \
    ninja install                                                           && \
    cd ..                                                                   && \
    rm -rf geant4 geant4-build "geant4.$DOCKER_TAG.tar.gz"                     \
           /usr/local/geant4/share/Geant4-*/examples 

# Set the entry point
COPY entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD [ "/bin/bash" ]
