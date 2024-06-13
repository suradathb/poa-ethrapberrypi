# Start from an official Geth image
FROM ethereum/client-go:stable

# Expose necessary ports
EXPOSE 8545 30303

# Copy genesis file
COPY genesis.json /root/genesis.json

# Create directory for Ethereum data
RUN mkdir -p /root/.ethereum

# Set working directory to Ethereum data directory
WORKDIR /root/.ethereum
