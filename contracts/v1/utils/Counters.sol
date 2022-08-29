// SPDX-License-Identifier: MIT
// QIYICHAIN Contracts v1.0.0 (utils/Counters.sol)

pragma solidity >=0.6.0 <0.8.0;

library Counters {
    struct Counter {
        uint256 _value;     // default 0
        uint256 _count;     // default 0
    }

    function current(Counter storage counter) internal view returns (uint256, uint256) {
        return (counter._value, counter._count);
    }

    function increment(Counter storage counter, uint256 value) internal {
        // storage old counter value 
        uint256 _old = counter._value;      

        // increment
        counter._value += value;            
        counter._count += 1;                

        // check overflow
        require(_old < counter._value, "Counter: increment overflow.");     
    }

    function decrement(Counter storage counter, uint256 value) internal {
        // storage old counter value 
        uint256 _old = counter._value;      
        
        // decrement 
        counter._value -= value;
        counter._count -= 1;

        // check overflow
        require(_old > counter._value, "Counter: decrement overflow");
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
        counter._count = 0;
    }
}