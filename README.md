- run commands from https://docs.sui.io/devnet/build/install (Install Sui -> Linux prerequisites + Install Sui binaries):
    - sudo apt-get update
    - curl --version
    - sudo apt-get install git-all
    - sudo apt-get install libssl-dev
    - sudo apt-get install libclang-dev
    - cargo install --locked --git https://github.com/MystenLabs/sui.git --branch devnet sui
- run "npm run build"
- (create account) run "sui client"
    - "doesn't exist, do you want to connect to a Sui Full node server" - y
    - "Sui Full node server URL" - https://fullnode.testnet.sui.io:443/
    - "Environment alias for [testnet]:" - testnet
    - "Select key scheme to generate keypair (0 for ed25519, 1 for secp256k1, 2: for secp256r1)" - 0
    - save address and Secret Recovery Phrase
    - run "sui client active-env" (must be "testnet")
- (get tokens) run "sui client active-address"
    - copy
    - join to sui discord https://discord.gg/sui
    - find channel testnet-faucet
        - type "!faucet <address>"
- (deploy)run "npm run deploy"
- copy addresses from log and past into ./post-action-scripts/.env
    - PACKAGE
    - PERIOD_REWARD_CONTAINER
    - USERS_RATING_COLLECTION
- run "cd ./post-action-scripts"
- run "./create-user"
    - copy addresses from log and past into ./post-action-scripts/.env
    - USER
    - USER_COMMUNITY_RATING
- run "./create-community"
    - copy addresses from log and past into ./post-action-scripts/.env
    - COMMUNITY


new version sui:
- run commant from 1 block ↑
- run "npm run build"
- run "npm run deploy"
if error (Cannot open wallet config file at "/home/freitag/.sui/sui_config/client.yaml")
    - open /home/freitag/.sui/sui_config/client.yaml file
    - back to .sui folder
    - delete folder sui_config
    run command from block "(create account) run "sui client""
        sui client...
