# Multicall-Based Uniswap Price Retrieval Solution

A solution that leverages the concept of multicalls to efficiently retrieve multiple token prices from Uniswap, by reducing the number of calls to the blockchain node.

### Considerations
- An ethereum mainnet fork is setup in the `hardhat.config.js`
- The default base token for price retrieval is set to WETH
- The uniswapV3 price oracle is used to calculate ( time weighted average price )
- The `.env.example` is a sample file of the node url, make a `.env` with the example reference and put your node url ( preferebly alchemy/infura )
- `.nvmrc` file is set to node version `16.14.2`

Try running some of the following commands:

```shell
npm install
npx hardhat compile
npx hardhat test
```

Create your own mainnet fork : `npx hardhat node --fork <MAINNET_NODE_URL>`
