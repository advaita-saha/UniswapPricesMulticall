const { expect } = require("chai")
const { ethers } = require("hardhat");
const { int } = require("hardhat/internal/core/params/argumentTypes");

const TOKENS = [
    "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48", // USDC
    "0xdAC17F958D2ee523a2206206994597C13D831ec7", // USDT
    "0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984", // UNI
    "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599", // WBTC
    "0x4d224452801ACEd8B2F0aebE155379bb5D594381", // APE
];
const BASE_TOKEN = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"; // WETH
const FEE = 3000

beforeEach( async () => {
    accounts = await ethers.getSigners();
    const contractFactory = await ethers.getContractFactory("FetchPricesFromUniswapOracle");
    contract = await contractFactory.deploy(
        BASE_TOKEN,
        FEE
    );
    await contract.deployed();
    for(let i=0; i<TOKENS.length; i++){
        await contract.addTokenToIndex(TOKENS[i]);
    }

});

describe("FetchPricesFromUniswapOracle", () => {

    it("add tokens", async () => {
        const tokens = await contract.getAssets();
        expect(tokens).to.deep.equal(TOKENS);
    });

    it("get prices using multicall", async () => {
        const prices = await contract.getAllPrices();
        for(let i=0; i<prices.length; i++){
            console.log(`${TOKENS[i]} price is : ${parseInt(prices[i], 16)} WETH(base token)`);
        }
    });

    // it("get price", async () => {
    //     const UniswapV3Twap = await ethers.getContractFactory("UniswapV3Twap")
    //     const twap = await UniswapV3Twap.deploy(FACTORY, TOKEN_0, TOKEN_1, FEE)
    //     await twap.deployed()

    //     const price = await twap.estimateAmountOut(TOKEN_1, 10n ** DECIMALS_1, 10)

    //     console.log(`price: ${price}`)
    // })
})