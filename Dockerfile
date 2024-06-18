<<<<<<< HEAD
FROM ethereum/client-go:v1.10.1

ARG ACCOUNT_PASSWORD

COPY genesis.json .

RUN geth init ./genesis.json \
    && rm -f ~/.ethereum/geth/nodekey \
    && echo ${ACCOUNT_PASSWORD} > ./password.txt \
    && geth account new --password ./password.txt \
    && rm -f ./password.txt

ENTRYPOINT ["geth"]
=======
# Use ARM-based Ubuntu as the base image
FROM arm64v8/ubuntu:latest

# Update package list and install necessary packages
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    software-properties-common \
    && add-apt-repository -y ppa:ethereum/ethereum \
    && apt-get update \
    && apt-get install -y geth

# Optional: Set the PATH environment variable if needed
# ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Optional: Create a directory for Ethereum data (e.g., blockchain data)
# RUN mkdir -p /root/.ethereum

# Copy your application and configuration files (if needed)
# COPY . /app

# Set the working directory (if needed)
# WORKDIR /app

# Specify the default command to run
CMD ["geth", "--help"]
>>>>>>> 4cab1687e3d62c30074766b9967e168731007998
