// SPDX-License-Identifier: MIT
// QIYICHAIN Contracts v1.0.0 (Transfers.sol)

pragma solidity >= 0.6.0 < 0.8.0;

import "./utils/Context.sol";
import "./utils/Ownable.sol";
import "./utils/Counters.sol";
import "./utils/Pausable.sol";
import "./library/SafeMath.sol";
import "./library/ReentrancyGuard.sol";


contract Transfer is Context, Ownable, Pausable, ReentrancyGuard {

    // address public operator;
    mapping(address => bool) public operators;

    // gasLimit
    uint256 public transGasLimit;

    using SafeMath for uint256;
    using Counters for Counters.Counter;
    Counters.Counter internal _PayedCounter;

    fallback() external payable {
        revert('Invalid.');
    }

    receive() external onlyOperator payable {
        revert('Invalid.');
    }

    constructor(address[] memory operatorList, uint256 gasLimit) {

        for (uint256 i = 0; i < operatorList.length; i++) {
            _updateOperator(operatorList[i], true);
        }
        
        // todo: default gasLimit = 2300?
        transGasLimit = gasLimit;
        emit GasLimitChange(0, gasLimit);
    }
    
    // deprecated
    // modifier operatorExist() {
    //     require(operator != address(0), "Operator not exist.");
    //     _;
    // }

    modifier onlyOperator() {
        address _sender = _msgSender();
        require(operators[_sender], "Only operator can transfer.");
        _;
    }

    // events
    event OperatorUpdated(address operator, bool enabled);
    event TransferToken(address receiver, uint256 value);
    event GasLimitChange(uint256 prevGasLimit, uint256 newGasLimit);
    event WithdrawToken(address owner, uint256 value);
    event Refound(address receiver, uint256 value);

    // for operator 
    function _updateOperator(address newOperator, bool enabled) internal {
        require(newOperator != address(0), "Invalid operator address.");
        operators[newOperator] = enabled;
        emit OperatorUpdated(newOperator, enabled);
    }

    function UpdateOperator(address[] memory operatorList, bool[] memory enabled) external onlyOwner whenNotPaused {
        require(operatorList.length == enabled.length, "OperatorList length must be equal to enabled length.");
        for (uint256 i = 0; i < operatorList.length; i++) {
            _updateOperator(operatorList[i], enabled[i]);
        }
    }

    // for Transfer
    function _transfer(address receiver, uint256 value) internal returns (bool success) {
        require(receiver != address(0), "Receiver not exist.");
        // todo: check gas
        (success, ) = receiver.call{
            value: value,
            gas: transGasLimit
        }('');
        emit TransferToken(receiver, value);

        // storage 
        _PayedCounter.increment(value);
    }

    function BatchTransfer(address[] calldata recipients, uint256[] calldata values) 
        external 
        payable 
        onlyOperator
        whenNotPaused
        nonReentrant {
            require(recipients.length != 0, "Recipents length must be non-zero");
            require( recipients.length == values.length, "Recipents and Values must have the same length");
            // make sure that values are enough for the recipients
            uint256 _value = 0;
            for (uint i = 0; i < recipients.length; i++) {
                _value = _value + values[i];
            }
            require(_value <= _msgValue(), "Insufficient founds.");

            // transfer
            for (uint256 i=0; i<recipients.length; i++) {
                require(_transfer(recipients[i], values[i]), "Send failed.");
            }
        }

    // for GasLimit
    function TransGasLimitChg(uint256 newGasLimit) external onlyOperator whenNotPaused {
        require(newGasLimit >= 2300, "New gasLimit too low");
        emit GasLimitChange(transGasLimit, newGasLimit);
        transGasLimit = newGasLimit;
    }
    
    // for Pausable
    function Pause() external onlyOwner {
        _pause();
    }

    function UnPause() external onlyOwner {
        _unpause();
    }

    // for Counter
    function CounterCurrent() external view returns (uint256, uint256) {
        return _PayedCounter.current();
    }

    function CounterReset() external onlyOwner onlyOwner {
        _PayedCounter.reset();
    }

    // for withdraw
    function Withdraw() external onlyOwner whenPaused {
        address payable _to = payable(_msgSender());
        uint256 _value = address(this).balance;

        (bool success, ) = _to.call{ value: _value }('');
        require(success, "Withdraw failed.");
        emit WithdrawToken(_to, _value);
    }

}