pragma solidity ^0.8.13;

import "./SaSiERC20.sol";

import "../libraries/Math.sol";
import "../libraries/UQ112x122.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/ISaSiFactory.sol";
import "../interfaces/IERC1155Burnable.sol";
import "../../lib/openzeppelin-contracts/contracts/token/ERC1155/IERC1155Receiver.sol";

// import "./interfaces/IUniswapV2Callee.sol";

/**
 * @title SaSiPair
 * @author SaSi team
 * @notice Since this contract will be inside a permissioned EVM-compatible blockchain, we, therefore, decided to make some assumptions. NOTE that removing these assumptions make this contract to be vulnerable to be deployed in any EVM-compatible mainnet. The assumptions are below:
 * 1.
 */

contract SaSiPair is SaSiERC20, IERC1155Receiver {
    using SafeMath for uint;
    using UQ112x112 for uint224;

    // errors
    error Pair_Forbidden();
    error Pair_Overflow(uint balance0, uint balance1);
    error Pair_Insufficient_Minted();
    error Pair_Insufficient_Output();
    error Pair_Insufficient_Input();
    // here uint >= uint112 comparison is made.
    error Pair_Insufficient_Liquidity(uint amount1, uint amount2);
    error Pair_Invalid_To();
    error Pair_NotExpired();
    error Pair_SaSi_K();
    error Pair_GovHasNotApprovedPool();
    error Pair_LengthMistach(uint length1, uint length2);

    uint public constant MINIMUM_LIQUIDITY = 10 ** 3;
    bytes4 private constant ERC20_SELECTOR =
        bytes4(keccak256(bytes("transfer(address,uint256)")));
    bytes4 private constant ERC1155_SELECTOR =
        bytes4(
            keccak256(
                bytes("safeTransferFrom(address,address,uint256,uint256,bytes)")
            )
        );

    ISaSiFactory public factory;
    address public token0;
    address public token1;
    address rewardToken;
    bool distribute;

    // ADDED BY CAIO
    uint public initialPrice0;
    uint public initialPrice1;
    uint public ID; // ERC1155 tokenID.

    uint112 public reserve0; // uses single storage slot, accessible via getReserves
    uint112 public reserve1; // uses single storage slot, accessible via getReserves
    uint32 private blockTimestampLast; // uses single storage slot, accessible via getReserves

    uint public price0CumulativeLast;
    uint public price1CumulativeLast;
    uint public kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event

    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, "SaSi: LOCKED");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function getReserves()
        public
        view
        returns (
            uint112 _reserve0,
            uint112 _reserve1,
            uint32 _blockTimestampLast
        )
    {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

    function _safeTransferERC20(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(ERC20_SELECTOR, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "SaSi: ERC20_TRANSFER_FAILED"
        );
    }

    function _safeTransferERC1155(
        address token,
        address from,
        address to,
        uint id,
        uint value
    ) private {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(ERC1155_SELECTOR, from, to, id, value, "0x")
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "SaSi: ERC1155_TRANSFER_FAILED"
        );
    }

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(
        address indexed sender,
        uint amount0,
        uint amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint id,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    constructor() public {
        factory = ISaSiFactory(msg.sender);
    }

    // called once by the factory at time of deployment
    function initialize(
        address _token0,
        address _token1,
        uint _amount0,
        uint _amount1,
        uint _id
    ) external {
        if (msg.sender != address(factory)) revert Pair_Forbidden();

        token0 = _token0;
        token1 = _token1;
        // initial price
        initialPrice0 = _amount0;
        initialPrice1 = _amount1;
        // id
        ID = _id;
    }

    // update reserves and, on the first call per block, price accumulators
    function _update(
        uint balance0,
        uint balance1,
        uint112 _reserve0,
        uint112 _reserve1
    ) private {
        if (balance0 > type(uint112).max || balance1 > type(uint112).max)
            revert Pair_Overflow(balance0, balance1);
        uint32 blockTimestamp = uint32(block.timestamp % 2 ** 32);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            // * never overflows, and + overflow is desired
            price0CumulativeLast +=
                uint(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) *
                timeElapsed;
            price1CumulativeLast +=
                uint(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) *
                timeElapsed;
        }
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
        blockTimestampLast = blockTimestamp;
        emit Sync(reserve0, reserve1);
    }

    // if fee is on, mint liquidity equivalent to 1/6th of the growth in sqrt(k)
    function _mintFee(
        uint112 _reserve0,
        uint112 _reserve1
    ) private returns (bool feeOn) {
        address feeTo = ISaSiFactory(factory).feeTo();
        feeOn = feeTo != address(0);
        uint _kLast = kLast; // gas savings
        if (feeOn) {
            if (_kLast != 0) {
                uint rootK = Math.sqrt(uint(_reserve0).mul(_reserve1));
                uint rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint numerator = totalSupply.mul(rootK.sub(rootKLast));
                    uint denominator = rootK.mul(5).add(rootKLast);
                    uint liquidity = numerator / denominator;
                    if (liquidity > 0) _mint(feeTo, liquidity);
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }

    // this low-level function should be called from a contract which performs important safety checks
    function mint(address to) external lock returns (uint liquidity) {
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves(); // gas savings
        uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC1155(token1).balanceOf(address(this), ID);
        uint amount0 = balance0.sub(_reserve0);
        uint amount1 = balance1.sub(_reserve1);

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        if (_totalSupply == 0) {
            // Answer: https://ethereum.stackexchange.com/questions/132491/why-minimum-liquidity-is-used-in-dex-like-uniswap
            liquidity = Math.sqrt(amount0.mul(amount1)).sub(MINIMUM_LIQUIDITY);
            _mint(address(0), MINIMUM_LIQUIDITY); // permanently lock the first MINIMUM_LIQUIDITY tokens
        } else {
            liquidity = Math.min(
                amount0.mul(_totalSupply) / _reserve0,
                amount1.mul(_totalSupply) / _reserve1
            );
        }
        if (liquidity == 0) revert Pair_Insufficient_Minted();
        require(liquidity > 0, "SaSi: INSUFFICIENT_LIQUIDITY_MINTED");
        _mint(to, liquidity);

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date
        emit Mint(msg.sender, amount0, amount1);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function burn(
        address to
    ) external lock returns (uint amount0, uint amount1) {
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves(); // gas savings
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings
        uint balance0 = IERC20(_token0).balanceOf(address(this));
        uint balance1 = IERC1155(_token1).balanceOf(address(this), ID);
        uint liquidity = balanceOf[address(this)];

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        amount0 = liquidity.mul(balance0) / _totalSupply; // using balances ensures pro-rata distribution
        amount1 = liquidity.mul(balance1) / _totalSupply; // using balances ensures pro-rata distribution
        require(
            amount0 > 0 && amount1 > 0,
            "SaSi: INSUFFICIENT_LIQUIDITY_BURNED"
        );
        _burn(address(this), liquidity);
        _safeTransferERC20(_token0, to, amount0);
        _safeTransferERC1155(_token1, address(this), to, ID, amount1);
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC1155(_token1).balanceOf(address(this), ID);

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date
        emit Burn(msg.sender, amount0, amount1, to);
    }

    function _isGov(address account) internal view {
        if (account != factory.govBr()) revert Pair_Forbidden();
    }

    function burnByGov(address token, uint rewards) external lock {
        /*
        We should transfer from the gov the adequate quantity of tokens CDBC to burn the titles. Function is called by Gov when title's expired.
        */
        _isGov(msg.sender);
        // if gov hasn't approved ourselves to burn his tokens, then do not let gov burn his titles & distribute rewards.
        if (!IERC1155(token1).isApprovedForAll(address(this), msg.sender))
            revert Pair_GovHasNotApprovedPool();
        IERC20(token).transferFrom(msg.sender, address(this), rewards);
        // should we really burn the initialPrice1 ?
        IERC1155Burnable(token1).burn(msg.sender, ID, initialPrice1);
        // distribute to holders, which are only the banks
        setDistribute(true, token);
    }

    // holders are checked off-chain
    function distributeRewards(
        address[] memory holders,
        uint[] memory rewards
    ) external {
        if (!distribute) revert Pair_NotExpired();
        uint holdersLength = holders.length;
        if (rewards.length != holdersLength)
            revert Pair_LengthMistach(rewards.length, holdersLength);
        for (uint i; i < holdersLength; ) {
            IERC20(rewardToken).transfer(holders[i], rewards[i]);
        }
        // set it paused so that contract won't have anymore interaction.
    }

    function setDistribute(bool _begin, address _rewardToken) private {
        distribute = _begin;
        rewardToken = _rewardToken;
    }

    // this low-level function should be called from a contract which performs important safety checks
    function swap(uint amount0Out, uint amount1Out, address to) external lock {
        if (amount0Out == 0 && amount1Out == 0)
            revert Pair_Insufficient_Output();
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves(); // gas savings
        if (amount0Out >= _reserve0 && amount1Out >= _reserve1)
            revert Pair_Insufficient_Liquidity(amount0Out, amount1Out);
        uint balance0;
        uint balance1;
        {
            // scope for _token{0,1}, avoids stack too deep errors
            address _token0 = token0;
            address _token1 = token1;
            if (to == _token0 || to == _token1) revert Pair_Invalid_To();

            if (amount0Out > 0) _safeTransferERC20(_token0, to, amount0Out); // optimistically transfer tokens
            if (amount1Out > 0)
                _safeTransferERC1155(
                    _token1,
                    address(this),
                    to,
                    ID,
                    amount1Out
                );
            balance0 = IERC20(_token0).balanceOf(address(this));
            balance1 = IERC1155(_token1).balanceOf(address(this), ID);
        }
        uint amount0In = balance0 > _reserve0 - amount0Out
            ? balance0 - (_reserve0 - amount0Out)
            : 0;
        uint amount1In = balance1 > _reserve1 - amount1Out
            ? balance1 - (_reserve1 - amount1Out)
            : 0;
        if (amount0In == 0 && amount1In == 0) revert Pair_Insufficient_Input();
        {
            // scope for reserve{0,1} Adjusted, avoids stack too deep errors
            uint balance0Adjusted = balance0.mul(1000).sub(amount0In.mul(3));
            uint balance1Adjusted = balance1.mul(1000).sub(amount1In.mul(3));
            if (
                balance0Adjusted.mul(balance1Adjusted) <
                uint(_reserve0).mul(_reserve1).mul(1000 ** 2)
            ) revert Pair_SaSi_K();
        }
        _update(balance0, balance1, _reserve0, _reserve1);
        emit Swap(
            msg.sender,
            amount0In,
            amount1In,
            ID,
            amount0Out,
            amount1Out,
            to
        );
    }

    // force balances to match reserves
    function skim(address to) external lock {
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings
        _safeTransferERC20(
            _token0,
            to,
            IERC20(_token0).balanceOf(address(this)).sub(reserve0)
        );
        _safeTransferERC1155(
            _token1,
            address(this),
            to,
            ID,
            IERC1155(_token1).balanceOf(address(this), ID).sub(reserve1)
        );
    }

    // force reserves to match balances
    function sync() external lock {
        _update(
            IERC20(token0).balanceOf(address(this)),
            IERC1155(token1).balanceOf(address(this), ID),
            reserve0,
            reserve1
        );
    }

    // IERC1155Receiver
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155Received(address,address,uint256,uint256,bytes)"
                )
            );
    }

    function supportsInterface(
        bytes4 interfaceId
    ) external pure returns (bool) {
        if (interfaceId == bytes4(0x36372b07)) return true;
        return false;
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"
                )
            );
    }
}
