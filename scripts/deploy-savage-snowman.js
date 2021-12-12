// const updateEnv = require('./updateEnv.js');

async function main() {

    const [deployer] = await ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);
    console.log("Account balance:", (await deployer.getBalance()).toString());

    const ProceedsPayments = await ethers.getContractFactory("ProceedsPayments")
    const RoyaltyPayments = await ethers.getContractFactory("RoyaltyPayments")
    const SavageSnowman = await ethers.getContractFactory("SavageSnowmen")

    const proceedsPaymentsContract = await ProceedsPayments.deploy(
        // [
        //     "0x1FF0a45474f1588922aF70DE2ee78036193f289e",
        //     "0x234cD3A5335B590872f7888d8E72DbA72492190b",
        //     "0x1f9754318066b27EaCB747D5EB22777CA0ecC020",
        //     "0x4e9Bead20B8F9B8a82F8440F16E70200639E71Db",
        //     "0x4E039B8DDb5048139e98D2bf70171BFc6d10f312"
        // ],
        [
            "0x9632a79656af553F58738B0FB750320158495942",
            "0x55ee05dF718f1a5C1441e76190EB1a19eE2C9430",
            "0x4Cf2eD3665F6bFA95cE6A11CFDb7A2EF5FC1C7E4",
            "0x0B891dB1901D4875056896f28B6665083935C7A8",
            "0x01F253bE2EBF0bd64649FA468bF7b95ca933BDe2"
        ],
        [
            20,
            8,
            3,
            41,
            28
        ]
    )

    console.log("Proceeds Payments deployed to address:", proceedsPaymentsContract.address)

    const royaltyPaymentsContract = await RoyaltyPayments.deploy(
        // [
        //     "0x1FF0a45474f1588922aF70DE2ee78036193f289e",
        //     "0x234cD3A5335B590872f7888d8E72DbA72492190b",
        //     "0x4e9Bead20B8F9B8a82F8440F16E70200639E71Db",
        //     "0x4E039B8DDb5048139e98D2bf70171BFc6d10f312"
        // ],
        [
            "0x9632a79656af553F58738B0FB750320158495942",
            "0x55ee05dF718f1a5C1441e76190EB1a19eE2C9430",
            "0x4Cf2eD3665F6bFA95cE6A11CFDb7A2EF5FC1C7E4",
            "0x0B891dB1901D4875056896f28B6665083935C7A8"
        ],
        [
            46,
            18,
            18,
            18
        ]
    )

    console.log("Royalty Payments deployed to address:", royaltyPaymentsContract.address)
    
    // string memory name,
    // string memory symbol,
    // string memory tokenBaseURI,
    // uint256 cap,
    // address proceedsAddress
    // address royaltiesAddress
    const savageSnowmenContract = await SavageSnowman.deploy(
        "SavageSnowmen",
        "SS",
        "ipfs://Qmcu89CVUrz1dEZ8o32qnQnN4myurbAFr162w1qKLCKAA8/",
        10000,
        proceedsPaymentsContract.address,
        royaltyPaymentsContract.address
    )

    // uncomment if .env file is present. it will update the CONTRACT_ADDRESS variable
    // const envUpdate = {
    //     'CONTRACT_ADDRESS': savageSnowmenContract.address
    // }
    // updateEnv(envUpdate)

    console.log("Savage Snowmen deployed to address:", savageSnowmenContract.address)
}

  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error)
      process.exit(1)
    })
