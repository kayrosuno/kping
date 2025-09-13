# syntax=docker/dockerfile:1



# Build the application from source
FROM golang:latest AS build-stage

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY *.go ./

RUN CGO_ENABLED=0 GOOS=linux go build -o /app/qping

# Run the tests in the container
#FROM build-stage AS run-test-stage
#RUN go test -v ./...

# Deploy the application binary into a clean image
FROM ubuntu:latest AS build-release-stage

#Instalar net-tools
RUN apt-get update && apt-get -qq -y install curl
RUN apt-get install -y apt-utils
RUN apt-get install -y net-tools
RUN apt-get install -y iproute2
RUN apt-get install -y iputils-ping


ARG USERNAME=iacobus
ARG USER_UID=2000
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# ********************************************************
# * Anything else you want to do like clean up goes here *
# ********************************************************

# [Optional] Set the default user. Omit if you want to keep the default as root.
USER $USERNAME


# Label docker image
LABEL version="0.3.2"
LABEL maintaner="Alejandro Garcia"
LABEL release-date="04-07-2025"
#LABEL promoted="true"



WORKDIR /app

COPY --from=build-stage /app/qping /app/qping

EXPOSE 25450/udp

#Ejecuta qping en modo server, default port 25450 UDP (QUIC)
ENTRYPOINT ["/app/qping","server"]