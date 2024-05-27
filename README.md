# Private Blockchain with Proof of Authority (PoA) on Raspberry Pi using Docker
# Blockchain ส่วนตัวพร้อม Proof of Authority (PoA) บน Raspberry Pi โดยใช้ Docker

This guide explains how to set up a private blockchain using Geth with Proof of Authority (PoA) consensus on multiple Raspberry Pi devices using Docker. The steps cover everything from installation to deploying smart contracts.
คู่มือนี้จะอธิบายวิธีตั้งค่าบล็อกเชนส่วนตัวโดยใช้ Geth พร้อมหลักฐานการอนุญาต (PoA) ที่เป็นเอกฉันท์บนอุปกรณ์ Raspberry Pi หลายเครื่องโดยใช้ Docker ขั้นตอนครอบคลุมทุกอย่างตั้งแต่การติดตั้งไปจนถึงการปรับใช้สัญญาอัจฉริยะ

## Prerequisites
## ข้อกำหนดเบื้องต้น

- 3 Raspberry Pi devices
- Docker and Docker Compose installed on each Raspberry Pi
- Basic understanding of blockchain concepts and Docker
- อุปกรณ์ Raspberry Pi 3 เครื่อง
- ติดตั้ง Docker และ Docker Compos บน Raspberry Pi แต่ละตัว
- ความเข้าใจพื้นฐานเกี่ยวกับแนวคิดบล็อคเชนและนักเทียบท่า

## Step 1: Install Docker and Docker Compose
## ขั้นตอนที่ 1: ติดตั้ง Docker และ Docker Compose

1. **Install Docker**:
    ```bash
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    sudo usermod -aG docker $USER
    ```
    Logout and login again for the changes to take effect.
    ออกจากระบบและเข้าสู่ระบบอีกครั้งเพื่อให้การเปลี่ยนแปลงมีผล.

2. **Install Docker Compose**:
    ```bash
    sudo apt-get install -y libffi-dev libssl-dev
    sudo apt-get install -y python3 python3-pip
    sudo pip3 install docker-compose
    ```

## Step 2: Create and Configure the Genesis Block for PoA
## ขั้นตอนที่ 2: สร้างและกำหนดค่า Genesis Block สำหรับ PoA

1. **On one of the Raspberry Pi devices**, create the `genesis.json` file:
1. **บนอุปกรณ์ Raspberry Pi ตัวใดตัวหนึ่ง** ให้สร้างไฟล์ `genesis.json`:
    ```bash
    mkdir ~/poa-blockchain
    cd ~/poa-blockchain
    nano genesis.json
    ```
    Add the following content to `genesis.json`:
    เพิ่มเนื้อหาต่อไปนี้ใน `genesis.json`:
    ```json
    {
      "config": {
        "chainId": 15,
        "homesteadBlock": 0,
        "eip150Block": 0,
        "eip155Block": 0,
        "eip158Block": 0,
        "clique": {
          "period": 1,
          "epoch": 30000
        }
      },
      "difficulty": "1",
      "gasLimit": "8000000",
      "alloc": {}
    }
    ```

## Step 3: Create Accounts and Configure PoA
## ขั้นตอนที่ 3: สร้างบัญชีและกำหนดค่า PoA

1. **On Raspberry Pi #1**, create a new account:
1. **บน Raspberry Pi #1** ให้สร้างบัญชีใหม่:
    ```bash
    docker run -it --rm -v $PWD:/root/.ethereum ethereum/client-go account new
    ```
    Repeat this step on each Raspberry Pi to create a new account and save the account addresses.
    ทำซ้ำขั้นตอนนี้กับ Raspberry Pi แต่ละตัวเพื่อสร้างบัญชีใหม่และบันทึกที่อยู่บัญชี

2. **Edit the `genesis.json` file to include the validator addresses**:
2. **แก้ไขไฟล์ `genesis.json` เพื่อรวมที่อยู่ของเครื่องมือตรวจสอบความถูกต้อง**:
    ```json
    {
      "config": {
        "chainId": 15,
        "homesteadBlock": 0,
        "eip150Block": 0,
        "eip155Block": 0,
        "eip158Block": 0,
        "clique": {
          "period": 1,
          "epoch": 30000
        }
      },
      "difficulty": "1",
      "gasLimit": "8000000",
      "alloc": {},
      "extradata": "0x0000000000000000000000000000000000000000000000000000000000000000<validator1_address>0000000000000000000000000000000000000000000000000000000000000000<validator2_address>0000000000000000000000000000000000000000000000000000000000000000<validator3_address>0000000000000000000000000000000000000000000000000000000000000000"
    }
    ```

## Step 4: Configure Docker Compose for Each Node
## ขั้นตอนที่ 4: กำหนดค่า Docker Compose สำหรับแต่ละโหนด

1. **Create a `docker-compose.yml` file on each Raspberry Pi**:
1. **สร้างไฟล์ `docker-compose.yml` บน Raspberry Pi แต่ละตัว**:
    ```bash
    nano docker-compose.yml
    ```
    Add the following content to `docker-compose.yml`:
    ```yaml
    version: '3.8'

    services:
      geth:
        image: ethereum/client-go:latest
        volumes:
          - ./data:/root/.ethereum
          - ./genesis.json:/root/genesis.json
        networks:
          ethereum:
        ports:
          - "8545:8545"
          - "30303:30303"
        command: [
          "--networkid", "15",
          "--http", "--http.addr", "0.0.0.0", "--http.port", "8545", "--http.api", "personal,db,eth,net,web3",
          "--allow-insecure-unlock",
          "--datadir", "/root/.ethereum",
          "--nodiscover",
          "--mine",
          "--miner.threads=1",
          "--unlock", "<your_account_address>",
          "--password", "/root/.ethereum/password.txt"
        ]

    networks:
      ethereum:
        driver: bridge
    ```

2. **Create a `password.txt` file on each Raspberry Pi**:
2. **สร้างไฟล์ `password.txt` บน Raspberry Pi แต่ละตัว**:
    ```bash
    nano password.txt
    ```
    Add the password for your account in the `password.txt` file.
    เพิ่มรหัสผ่านสำหรับบัญชีของคุณในไฟล์ `password.txt`

## Step 5: Initialize and Start Nodes
## ขั้นตอนที่ 5: เริ่มต้นและเริ่มโหนด

1. **Initialize the blockchain on each node**:
1. **เริ่มต้น blockchain ในแต่ละโหนด**:
    ```bash
    docker-compose run geth init /root/genesis.json
    ```

2. **Start the Geth nodes**:
2. **เริ่มโหนด Geth**:
    ```bash
    docker-compose up -d
    ```

## Step 6: Connect Nodes
## ขั้นตอนที่ 6: เชื่อมต่อโหนด

1. **Get the `enode` address of the first node**:
1. **รับที่อยู่ `enode` ของโหนดแรก**:
    ```bash
    docker exec -it <container_id> geth attach http://0.0.0.0:8545
    ```
    In the Geth console:
    ```javascript
    admin.nodeInfo.enode
    ```

2. **Add the `enode` address of the first node to the second and third nodes**:
2. **เพิ่มที่อยู่ `enode` ของโหนดแรกไปยังโหนดที่สองและสาม**:
    ```javascript
    admin.addPeer("enode://<enode-address>@<ip-address>:30303")
    ```

## Step 7: Deploy Smart Contract
## ขั้นตอนที่ 7: ปรับใช้สัญญาอัจฉริยะ

1. **Install Truffle**:
    ```bash
    npm install -g truffle
    ```

2. **Create a new Truffle project**:
    ```bash
    mkdir myproject
    cd myproject
    truffle init
    ```

3. **Configure Truffle in `truffle-config.js`**:
    ```javascript
    module.exports = {
      networks: {
        private: {
          host: "127.0.0.1",
          port: 8545,
          network_id: "*",
        },
      },
      compilers: {
        solc: {
          version: "0.8.0",
        },
      },
    };
    ```

4. **Write a smart contract in `contracts/MyContract.sol`**:
    ```solidity
    pragma solidity ^0.8.0;

    contract MyContract {
        string public message;

        constructor(string memory initialMessage) {
            message = initialMessage;
        }

        function updateMessage(string memory newMessage) public {
            message = newMessage;
        }
    }
    ```

5. **Create a migration file in `migrations/2_deploy_contracts.js`**:
    ```javascript
    const MyContract = artifacts.require("MyContract");

    module.exports = function (deployer) {
      deployer.deploy(MyContract, "Hello, Blockchain!");
    };
    ```

6. **Deploy the smart contract**:
    ```bash
    truffle migrate --network private
    ```

## Step 8: Interact with Smart Contract
## ขั้นตอนที่ 8: โต้ตอบกับสัญญาอัจฉริยะ

1. **Open the Truffle console**:
    ```bash
    truffle console --network private
    ```

2. **Create an instance of the deployed contract**:
    ```javascript
    const instance = await MyContract.deployed();
    ```

3. **Read the message from the contract**:
    ```javascript
    const message = await instance.message();
    console.log(message);
    ```

4. **Update the message in the contract**:
    ```javascript
    await instance.updateMessage("New Message", { from: "0xYourAccountAddress" });
    ```

5. **Verify the updated message**:
    ```javascript
    const newMessage = await instance.message();
    console.log(newMessage);
    ```

## Producing and Using Ether for Gas Fees
## การผลิตและการใช้อีเธอร์เป็นค่าธรรมเนียมก๊าซ

- When you start your nodes and begin mining in PoA mode, the validators will create new blocks, earning Ether that can be used for gas fees in transactions and deploying smart contracts.
- เมื่อคุณเริ่มต้นโหนดของคุณและเริ่มการขุดในโหมด PoA เครื่องมือตรวจสอบความถูกต้องจะสร้างบล็อกใหม่ เพื่อรับอีเธอร์ที่สามารถนำไปใช้เป็นค่าธรรมเนียมก๊าซในการทำธุรกรรมและการปรับใช้สัญญาอัจฉริยะ

## Conclusion

By following this guide, you will have set up a private blockchain on multiple Raspberry Pi devices using Docker and PoA. You will be able to interact with the blockchain, deploy smart contracts, and manage transactions effectively.
ด้วยการทำตามคำแนะนำนี้ คุณจะตั้งค่าบล็อกเชนส่วนตัวบนอุปกรณ์ Raspberry Pi หลายเครื่องโดยใช้ Docker และ PoA คุณจะสามารถโต้ตอบกับบล็อกเชน ปรับใช้สัญญาอัจฉริยะ และจัดการธุรกรรมได้อย่างมีประสิทธิภาพ

## …or create a new repository on the command line
** echo "# poa-ethrapberrypi" >> README.md
** git init
** git add README.md
** git commit -m "first commit"
** git branch -M main
** git remote add origin https://github.com/suradathb/poa-ethrapberrypi.git
** git push -u origin main


## …or push an existing repository from the command line
** git remote add origin https://github.com/suradathb/poa-ethrapberrypi.git
** git branch -M main
** git push -u origin main