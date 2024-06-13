FROM ethereum/client-go:stable

COPY genesis.json /root/genesis.json

CMD ["geth"]
