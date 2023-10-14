import { Contract } from "@stdlib/deploy";

/*
  TASK 1 - Counter 
  Implement a counter contract that will have 2 opcodes ('Add' / 'Subtract'),
  which adds or subtracts the received number (int32) from the number that is stored in the state (and stores the result back in the state).
  You also need to implement one getter with the name "counter" to get the current number from the state.
*/

interface Add {
  queryId: number;
  number: number;
}

interface Subtract {
  queryId: number;
  number: number;
}

class Task1 extends Contract {
    counter: number;

    init() {
      this.counter = 0;
    }

    receive(msg: Add) {
        this.counter += msg.number;
    }
    
    receive(msg: Subtract) {
        this.counter -= msg.number;
    }

    get counter(): number {
        return this.counter;
    }
}
