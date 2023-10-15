import { Address, Contract, Deployer } from "@tonclient/core";
import { Abi, Signer } from "@tonclient/types";

interface TokenNotification {
  queryId: bigint;
  amount: bigint;
  from: Address;
  forwardPayload: string;
}

interface TokenTransfer {
  queryId: bigint;
  amount: bigint;
  destination: Address;
  responseDestination?: Address;
  customPayload?: string;
  forwardTonAmount: bigint;
  forwardPayload: string;
}

class Task3Contract {
  private readonly contract: Contract;

  constructor(deployer: Deployer, admin: Address, jettonAddressA: Address, jettonAddressB: Address) {
    this.contract = deployer.wrap({
      abi: new Abi({
        type: "Contract",
        value: [
          {
            name: "getPrice",
            inputs: [{ name: "jetton", type: "address" }],
            outputs: [{ name: "price", type: "uint" }],
          },
          {
            name: "getBalance",
            inputs: [{ name: "jetton", type: "address" }],
            outputs: [{ name: "balance", type: "uint" }],
          },
        ],
      }),
      tvc: "<... код TVC контракта ...>",
    });
  }

  async getPrice(jetton: Address): Promise<number> {
    const result = await this.contract.runLocal({
      function_name: "getPrice",
      input: { jetton },
    });
    return result.decoded.output.price;
  }

  async getBalance(jetton: Address): Promise<number> {
    const result = await this.contract.runLocal({
      function_name: "getBalance",
      input: { jetton },
    });
    return result.decoded.output.balance;
  }

  async receiveTokenNotification(msg: TokenNotification): Promise<void> {
    // Implement your logic for handling TokenNotification
  }

  async tokenTransfer(msg: TokenTransfer): Promise<void> {
    // Implement your logic for handling TokenTransfer
  }
}

// Пример использования
async function example() {
  const deployer = new Deployer();
  const adminAddress = "<адрес администратора>";
  const jettonAddressA = "<адрес jetton A>";
  const jettonAddressB = "<адрес jetton B>";

  const task3Contract = new Task3Contract(deployer, adminAddress, jettonAddressA, jettonAddressB);

  // Пример вызова функций
  const jettonAAddress = "<адрес jetton A>";
  const priceA = await task3Contract.getPrice(jettonAAddress);
  console.log("Price of Jetton A:", priceA);

  const jettonBAddress = "<адрес jetton B>";
  const priceB = await task3Contract.getPrice(jettonBAddress);
  console.log("Price of Jetton B:", priceB);
}

// Вызываем пример использования
example().catch(console.error);
