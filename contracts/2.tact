import "@stdlib/deploy";

/*
  TASK 2 - Proxy 
  Create a contract that forwards all received TONs
  to the admin contract (whose address is set in init_store).
  Message from this proxy contract to the admin contract should contain:
    - Address of user who sent original message (should be stored in the outcoming body's data/bits)
    - Original message that proxy smart contract received from user (should be stored in the outcoming body's first ref)
  Also, if admin contract decides to reject message (if it sends to the proxy "Refund" message with opcode=0x44),
  proxy contract needs to forward all TONs (attached to Refund message) back to the user.
  User address will be provided in Refund message body as "sender".
  In refund transaction, it is important to have a check that the refund message came from the admin address
*/

message(0x44) Refund {
  queryId: Int as uint64;
  sender: Address;
}

interface RefundMessage {
  queryId: bigint;
  sender: address;
}

contract Task2 with Deployable {
  admin: Address;

  init(admin: Address) {
    self.admin = admin;
  }
  
  receive(msg: Refund) {
    const refundMessage: RefundMessage = {
      queryId: BigInt(msg.queryId),
      sender: msg.sender,
    };
    
    // Handle the refund message here
  }
  
  receive(msg: Slice) {
    // Handle other message types here
  }
}

// Контракт для пересылки TON и обработки Refund сообщений
class Task2Contract {
  private readonly admin: Address;
  private readonly contract: Contract;

  constructor(deployer: Deployer, admin: Address) {
    this.admin = admin;
    this.contract = deployer.wrap({
      abi: new Abi({
        type: "Contract",
        value: [
          {
            name: "refund",
            inputs: [
              { name: "queryId", type: "uint64" },
              { name: "sender", type: "address" },
            ],
            outputs: [],
          },
        ],
      }),
      tvc: `
        <... код TVC контракта ...>
      `,
    });
  }

  async sendTonsToAdmin(userAddress: Address, originalMessage: string): Promise<void> {
    // Подготавливаем сообщение с данными
    const message = {
      originalMessage,
      userAddress,
    };

    // Отправляем сообщение административному контракту
    await this.contract.sendMessage({
      address: this.admin,
      abi: new Abi({
        type: "Contract",
        value: [
          {
            name: "receive",
            inputs: [
              { name: "msg", type: "tuple" },
            ],
            outputs: [],
          },
        ],
      }),
      call_set: {
        function_name: "receive",
        input: { msg: message },
      },
    });
  }

  async handleRefund(refundMessage: RefundMessage): Promise<void> {
    // Проверяем, что сообщение пришло от административного контракта
    expect(refundMessage.sender).to.equal(this.admin);

    // Возвращаем TON пользователю
    await this.contract.sendMessage({
      address: refundMessage.sender,
      abi: new Abi({
        type: "Contract",
        value: [
          {
            name: "refund",
            inputs: [
              { name: "queryId", type: "uint64" },
              { name: "sender", type: "address" },
            ],
            outputs: [],
          },
        ],
      }),
      call_set: {
        function_name: "refund",
        input: refundMessage,
      },
    });
  }
}

// Пример использования
async function example() {
  const deployer = new Deployer();
  const adminAddress = "your_admin_address_here"; // Адрес административного контракта

  // Инициализация контракта
  const task2Contract = new Task2Contract(deployer, adminAddress);
  
  // Пример отправки TON административному контракту
  const userAddress = "user_address_here"; // Адрес пользователя
  const originalMessage = "original_message_here"; // Оригинальное сообщение
  await task2Contract.sendTonsToAdmin(userAddress, originalMessage);

  // Пример обработки Refund сообщения
  const refundMessage: RefundMessage = {
    queryId: BigInt(12345),
    sender: "sender_address_here", // Адрес пользователя, от которого пришло сообщение
  };
  await task2Contract.handleRefund(refundMessage);
}
