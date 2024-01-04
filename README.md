# Aptos Move Language Repository

This repository contains code written in the Aptos Move language, implementing various functions and structures for managing streaming transactions. The Move language is utilized within the Aptos blockchain framework.

## Table of Contents

- [Introduction](#introduction)
- [Usage](#usage)
- [Functions](#functions)
- [Structures](#structures)
- [Testing](#testing)
- [Contributing](#contributing)

## Introduction

The codebase within this repository focuses on creating and managing streaming transactions using the Aptos Move language. It implements functionalities for initiating streams, managing sender and receiver details, calculating balances, and checking the existence of streams.

## Usage

To utilize this code:

1. **Environment Setup:** Ensure you have the necessary environment set up to execute Aptos Move code.
2. **Compilation:** Compile the code using [Aptos Move compiler]().
3. **Deployment:** Deploy the compiled code onto the Aptos blockchain or execute in a simulated environment.

## Functions

### `init_module(account: &signer)`

- Initializes the module with necessary tables for sender streams, receiver streams, and user balances.

### `CreateStream(user: &signer, receiver: address, flow_rate: u64, duration: u64)`

- Creates a stream transaction between a sender and receiver with specified parameters like flow rate and duration.

### `IsSendStreamsPresent(user: address)`

- Checks if sender streams are present for a particular user.

### `IsReceiveStreamPresent(user: address)`

- Checks if receiver streams are present for a particular user.

### `getListOfStreams(user: address)`

- Retrieves a list of streams initiated by a specific sender.

### `getListOfReceiveStreams(user: address)`

- Retrieves a list of streams received by a specific receiver.

### `current_balance(user: address)`

- Calculates the current balance considering active streams and their flow rates.

## Structures

- `FluXtream_transaction`: Represents a streaming transaction with sender, receiver, flow rate, start and end times.
- `DifferenceAmount`: Holds information about the difference in amounts, tagged as positive or negative.
- `UserBalances`: Table structure for storing user balances.
- `Sender_streams` and `Receiver_streams`: Tables storing sender and receiver transactions respectively.
- `FlowingBalance`: Structure to manage flowing balances, considering flow rates and stream activity.

## Testing

Currently, the repository provides a commented-out test function (`test_create_friend`) for creating a stream transaction. To test this function, follow the provided instructions within the code.

## Contributing

Contributions to enhance functionalities, fix bugs, or optimize code are welcome! Fork the repository, make your changes, and submit a pull request.


