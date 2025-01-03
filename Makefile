-include .env

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

all: clean remove install update build

# Clean the repo
clean:
	@forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install:
	@forge install foundry-rs/forge-std --no-commit && forge install openzeppelin/openzeppelin-contracts --no-commit

# Update Dependencies
update:
	@forge update

build:
	@forge build

test:
	forge test

snapshot:
	@forge snapshot

format:
	@forge fmt

anvil:
	anvil

deploy:
	@forge script script/DeploySZUToken.s.sol:DeploySZUToken --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

deploy-sepolia:
	@forge script script/DeployOurToken.s.sol:DeployOurToken --rpc-url $(SEPOLIA_RPC_URL) --account $(ACCOUNT) --sender $(SENDER) --etherscan-api-key $(ETHERSCAN_API_KEY) --broadcast --verify
