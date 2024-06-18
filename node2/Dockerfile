# Use the appropriate base image for Raspberry Pi
FROM ethereum/client-go:stable

# Set up the working directory
WORKDIR /root

# Copy the genesis file, password file, and nodekey file
COPY genesis.json /root/genesis.json
COPY password.txt /root/password.txt
COPY nodekey /root/nodekey

# Expose the necessary ports
EXPOSE 8546 30303

# Command to initialize and run the geth node
CMD ["geth", "--datadir", "/root/.ethereum", "init", "/root/genesis.json"]
CMD ["geth", "--datadir", "/root/.ethereum", "--networkid", "1234", "--nodiscover", "--mine", "--http", "--http.addr", "0.0.0.0", "--http.port", "8546", "--http.corsdomain", "*", "--http.vhosts", "*", "--http.api", "admin,eth,net,web3,personal,txpool,miner", "--allow-insecure-unlock", "--unlock", "0", "--password", "/root/password.txt", "--nodekey", "/root/nodekey", "--verbosity", "3"]
