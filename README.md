# Bitcoin Implementation in Elixir

In this project, Bitcoin protocol has been implemented for peer-to-peer payments using Elixir. This project implements the key concepts of Bitcoin platform such as Wallets, Transactions, Miners, etc.

## Getting Started

Following are the steps for executing/testing the project:

### Prerequisites

#### Erlang

Please use Erlang >= 20.0, available at <https://www.erlang.org/downloads>.

#### Elixir

To install elixir on a Mac, `brew install elixir`.

### Compile the code

#### Build the project

    $ mix compile


## Working:

The parameter passed initiates that many nodes in the network. The number of miners in the network a re fixed, which can be tweaked in the helper.ex file. Every node has a corresponding wallet.

### Wallet

Wallet has been implemented using public_key, private_key, and address as its fields. 

    defstruct [:private_key, :public_key, :address]
The address field is a SHA256 hash of its public key. Address acts as the identification for a node, in that any node that wants to send bitcoins to other node must send it to the wallet's address.

### Transaction

Transaction has as a structure in bitcoin network with fields as version, inputs, outputs, public key and signature.

    defstruct [:ver, :no_of_inputs, :inputs, :no_of_outputs, :outputs, :hash, :public_key, :lock_time, :signature]

Bitcoin system doesn't behave like traditional account balance systems, i.e, it doesn't store balance anywhere. Instead amount of bitcoin a node has is calculated as the Unspent Output Transactions (UTXOs) that point to that node's wallet address.

Each node that wants to spend bitcoins must create a transaction object, then send it to be verified by a minor.

### Miner

Miners have been implemented as GenServers that take mining requests. Miners maintain a pool of verified transaction. The block size is set to 2, so when the number of transaction in the verified pool of transactions reached 2, miners pick those transaction to be mined into block and added to a blockchain.

Miners main role is to mine the block which involves solving a mathematical problem of finding a nonce - a number such that when its included in the block, the SHA256 hash of the block starts with a predetermined number of zeros (0s). Cuurently in our project, the difficulty of this problem, i.e, the number of 0s the hash should start with is 4.

## Test Cases

### How to run test cases:
    $ mix test

### Test Case Description

#### 1. test "validate genesis blocks generation"

Generates a genesis bloc k and checks the blockchain.

#### 2.  test "verify btc transfer"

Sends bitcoins from one to another and verifies Unspent Transaction Outputs (UTXOs) for validation.

#### 3. test "verify nonce and block addition"

Verifies if the block hash is in accordance with the difficulty level and that the block gets added to the blockchain.

#### 4. test "validate ownership of bitcoins"
Validates ownership of bitcoins for a node using its public key for spending

## Mining reward
Additionally, a bitcoin feature for rewarding miners for investing their computing resources for ming the blocks. These are incorporated as coinbase transaction - a special kind of transaction that does not have any input, and only has outputs.
Currently, the reward for mining a block is set to 1 bitcoin per block mined.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `project1` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:bitcoin, "~> 0.1.0"}
  ]
end
```
