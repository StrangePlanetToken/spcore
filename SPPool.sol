// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;
import "./Ownable.sol";
import "./SafeERC20.sol";
import "./ERC20.sol";
import "./PriceLibrary.sol";
import "./ReentrancyGuard.sol";
import "./ISPPMiner.sol";


library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint256(_at(set._inner, index)));
    }


    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}


contract SPPool is Ownable, ERC20, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private minters;
    EnumerableSet.AddressSet private admins;

    address public feeOwner;

    uint256 public constant blocksPerDay = 28800; 
    uint256 public constant sptPerDay = 4112.5e18;  
    uint256 public constant sptReward = 2056.25e18;  
    uint256 public constant sptPerBlock = 142795138888888880;  
    uint256 private totalDepositHashrate = 0;     

    IERC20 public spt;
    IERC20 public usdtToken;
    
    ISPPMiner public sppminer;
    
    address public pancake;
    address public dead = 0x000000000000000000000000000000000000dEaD;
    uint256 public startBlock;
    uint256 public lastReleaseDailyBlock;
    uint256 public lastReleaseRewardBlock;
    uint256 public lastUpdateBlock;
    uint256 public lastComputeBlock;
    uint256 public breakPercent;
    
    uint256 public minDeposit;
    uint256 public maxDeposit;

    mapping(address => uint256) public rewards;
    mapping(address => uint256) public rewardsToday;

    address[] public addresslist;

    uint256 public releasePercent;
    struct optionInfo{
        uint256 option;
        uint256 frozen;
        uint256 releaseAmt;
    }
    mapping(address => optionInfo) public optionInfos;

    struct DepositInfo {
        uint256 amtUsdt;
        uint256 amtSpt;
        uint256 hashrate;
        uint256 blockNumber;
        uint256 depositTime;
    }
    mapping(address=>DepositInfo) private deposits;

    uint256[] public historyBlockNumber; 
    uint256[] public historyTotalSupply;

    bool public firstReleased = false;

    event Deposit(address indexed _addr, uint256 _usdtAmt, uint256 _sptAmt);
    event Withdraw(address indexed _addr, uint256 _depositUsdt, uint256 _withdrawUsdt); 
    event WithdrawReward(address _addr, uint256 reward);
    event UpdateReward(address indexed _addr, uint256 _amt);
    event GetOptionReleased(address indexed _addr, uint256 _amt);
    event ReleaseOptionFirst(uint256 releaseTime);
    event ReleaseOptionDaily(uint256 releaseTime);
    event ReleaseOptionReward();

    constructor(
        IERC20 _usdtToken, 
        address _pancake, 
        IERC20 _spt,
        address _feeOwner,
        uint256 _startBlock
    ) 
    public ERC20 ("Strange Planet Pool Token","SPPT")
    {   
        usdtToken = _usdtToken;
        pancake = _pancake;
        spt = _spt;
        feeOwner = _feeOwner;
        startBlock = _startBlock;
        lastReleaseDailyBlock = _startBlock;
        lastReleaseRewardBlock = _startBlock;
        lastComputeBlock = _startBlock;
    }


    function setMinDeposit(uint256 _min) public onlyOwner {
        minDeposit = _min;
    }


    function setMaxDeposit(uint256 _max) public onlyOwner {
        maxDeposit = _max;
    }


    function addUser(address addr) public onlyMinter {
        addresslist.push(addr);
    }


    function mint(address _to, uint256 _amount) external override onlyMinter returns(bool) {
        _mint(_to,_amount);
        return true;
    }

    
    function burn(address _account, uint _amount) public override {
        _burn(_account, _amount);
    }
   

    function deposit( uint256 _usdtAmt, uint256 _sptAmt) public returns(bool) {
        uint256 price = getSptPrice(); 
        uint256 sptvalue = _sptAmt.mul(price).div(1e18);
    
        uint256 totalValue = (sptvalue.add(_usdtAmt)).div(1e18);     

        require(totalValue >= minDeposit, "SPP: the amount must be larger than minDeposit");
        require(totalValue <= maxDeposit, "SPP: the amount must be less than maxDeposit");
        uint256 hashrate = totalValue.mul(1e18);
        totalDepositHashrate = totalDepositHashrate.add(hashrate); 

        deposits[msg.sender].amtUsdt = _usdtAmt;
        deposits[msg.sender].amtSpt = _sptAmt;
        deposits[msg.sender].hashrate = hashrate;
        deposits[msg.sender].blockNumber = block.number;
        deposits[msg.sender].depositTime = now;

        usdtToken.safeTransferFrom(msg.sender, address(this), _usdtAmt);
        spt.safeTransferFrom(msg.sender, dead, _sptAmt.mul(75).div(100));
        spt.safeTransferFrom(msg.sender, feeOwner, _sptAmt.mul(25).div(100));
        
        _mint(msg.sender, hashrate);   
       
        sppminer.addInvitee(msg.sender);
        sppminer.referReward(msg.sender, hashrate);

        emit Deposit(msg.sender, _usdtAmt, _sptAmt);
        return true;
    }


    function withdraw() public returns(bool) {
         withdrawReward(); 

        uint256 depositUsdt = deposits[msg.sender].amtUsdt;
        uint256 depositBlock = deposits[msg.sender].blockNumber;
        uint256 hashrate = deposits[msg.sender].hashrate;

        uint256 blockNumber = block.number;
        uint256 depositEndblock =  depositBlock.add(blocksPerDay.mul(10));
        uint256 withdrawUsdt = depositUsdt.div(80).mul(100);        // withdraw all
        if (blockNumber < depositEndblock) { 
            uint256 breakAmt =  withdrawUsdt.mul(breakPercent).div(100);
            withdrawUsdt = withdrawUsdt.sub(breakAmt) ;
        }
        usdtToken.safeTransfer(msg.sender, withdrawUsdt);
        
        _burn(msg.sender, hashrate);
        totalDepositHashrate = totalDepositHashrate.sub(hashrate);
        
        deposits[msg.sender].amtUsdt = 0;
        deposits[msg.sender].amtSpt = 0;
        deposits[msg.sender].hashrate = 0;
        sppminer.subInvitee(msg.sender);
        
        emit Withdraw(msg.sender, depositUsdt, withdrawUsdt);

        return true;
    }


    function withdrawReward() public  {
        uint256 reward = getEarned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            spt.transfer(msg.sender,reward);
        }
        emit WithdrawReward(msg.sender,reward);
    }


    function getDepositInfoUsdt(address account) public view returns(uint256 amtUsdt){
        return deposits[account].amtUsdt;
    }
    function getDepositInfoSpt(address account) public view returns( uint256 amtSpt){
        return deposits[account].amtSpt;
    }
    function getDepositInfoHashrate(address account) public view returns(uint256 hashrate){
        return balanceOf(account);
    }
    function getDepositInfoTime(address account) public view returns(uint256 depositTime){
        return deposits[account].depositTime;
    }


    function getEarned(address account) public view returns (uint256) {
        return rewards[account];
    }


    /**
    * init the option info
     */
    function initOptionInfo() public onlyAdmin {
        uint256 size = optionUserAdds.length;
        for(uint i=0; i<size; i++){
            optionInfos[optionUserAdds[i]].option = optionAmt[i];
            optionInfos[optionUserAdds[i]].frozen = optionAmt[i];
            addresslist.push(optionUserAdds[i]);
        }
    }


    function computeReward() public onlyAdmin {
        uint256 blockNow = block.number;
        uint256 dlt = blockNow.sub(lastComputeBlock);

        for (uint256 index = 0; index < addresslist.length; index++) {
            address a = addresslist[index];
            uint256 balance = balanceOf(a);
            uint256 total = totalSupply();

            uint256 depositHR = deposits[a].hashrate;
            uint256 teamHR = balance.sub(depositHR);
            
            uint256 depositReward = sptPerBlock.div(2).mul(dlt).mul(depositHR).div(totalDepositHashrate);
            uint256 teamReward = sptPerBlock.div(2).mul(dlt).mul(teamHR).div(total.sub(totalDepositHashrate));
            uint256 reward = depositReward.add(teamReward);
            rewards[a] += reward;
            rewardsToday[a] += reward;
        }
        
        lastComputeBlock = blockNow;
    }


    function getPrice(address _tokenA, address _tokenB) public view returns(uint256 amtA, uint256 amtB) {
        return PriceLibrary.price(pancake, _tokenA, _tokenB);
    }


    function getSptPrice() public view returns(uint256){
        (, uint256 amtB) = PriceLibrary.price(pancake, address(spt), address(usdtToken));
        return amtB;
    }
    

     function setSppMiner(ISPPMiner _sppminer) public onlyOwner {
        sppminer = _sppminer;
    }


     function setReleasePercent(uint256 _percent) public onlyOwner{
         releasePercent = _percent;
     }


     function releaseOptionFirst() public onlyAdmin returns(bool) {
         if (firstReleased == false) {
            for(uint256 i=0; i<optionUserAdds.length; i++){
                uint256 releaseAmt = optionAmt[i].div(100).mul(5);
                optionInfos[optionUserAdds[i]].frozen -= releaseAmt;
                optionInfos[optionUserAdds[i]].releaseAmt += releaseAmt;
            }
            emit ReleaseOptionFirst(lastReleaseDailyBlock);
            return true;  
         } 
     }


    function releaseOptionDaily() public onlyAdmin returns(bool) {
        uint256 b = lastReleaseDailyBlock.add(blocksPerDay); 
        if(block.number >= b){
            lastReleaseDailyBlock = b;
            uint256 l = optionUserAdds.length;
            for(uint256 i=0; i<l; i++){
                uint256 releaseAmt = optionAmt[i].div(100).mul(releasePercent);
                uint256 frozen = optionInfos[optionUserAdds[i]].frozen;
                if (frozen > releaseAmt) {
                    optionInfos[optionUserAdds[i]].frozen -= releaseAmt;
                    optionInfos[optionUserAdds[i]].releaseAmt += releaseAmt;
                } else {
                    optionInfos[optionUserAdds[i]].frozen =0;
                    optionInfos[optionUserAdds[i]].releaseAmt += frozen;
                } 
            }
            emit ReleaseOptionDaily(lastReleaseDailyBlock);
            return true;
        } 
        return false;
    }


    function releaseOptionReward() public onlyAdmin returns(bool) {
        uint256 l = optionUserAdds.length;
        for(uint256 i=0; i<l; i++){
            address a = optionUserAdds[i];
            address[] memory childs =  sppminer.getMyChilders(a);
            uint256 tmpHr = 0;
            for(uint256 c=0; c< childs.length; c++){
                tmpHr += rewardsToday[childs[c]];
            }
            uint256 reward = tmpHr.div(10);
                
            uint256 rewardMax = optionAmt[i].div(100).mul(3);
            if (reward > rewardMax) {
                reward = rewardMax;
            } 
            uint256 frozen = optionInfos[optionUserAdds[i]].frozen;
            if (frozen > reward) {
                optionInfos[optionUserAdds[i]].frozen -= reward;
                optionInfos[optionUserAdds[i]].releaseAmt += reward;
            } else {
                optionInfos[optionUserAdds[i]].frozen =0;
                optionInfos[optionUserAdds[i]].releaseAmt += frozen;
            } 
        }

        emit ReleaseOptionReward();
        return true; 
    }


    function harvestOptionReleased() public {
        spt.safeTransfer(msg.sender, optionInfos[msg.sender].releaseAmt);
        emit GetOptionReleased(msg.sender, optionInfos[msg.sender].releaseAmt);
        optionInfos[msg.sender].releaseAmt= 0;
    }


    function getOptionInfoReleased(address addr) public view returns(uint256){
        return optionInfos[addr].releaseAmt;
    }


    function setBreakPercent(uint256 _breakPercent) public onlyAdmin{
        breakPercent = _breakPercent;
    }


    function addMinter(address _addMinter) external onlyOwner returns (bool) {
        require(_addMinter != address(0), "SPP: _addMinter is the zero address");
        return EnumerableSet.add(minters, _addMinter);
    }

    function delMinter(address _delMinter) external onlyOwner returns (bool) {
        require(_delMinter != address(0), "SPP: _delMinter is the zero address");
        return EnumerableSet.remove(minters, _delMinter);
    }

    function getMinterLength() public view returns (uint256) {
        return EnumerableSet.length(minters);
    }

    function isMinter(address account) public view returns (bool) {
        return EnumerableSet.contains(minters, account);
    }

    function getMinter(uint256 _index) external view onlyOwner returns (address){
        require(_index <= getMinterLength() - 1, "SPP: index out of bounds");
        return EnumerableSet.at(minters, _index);
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender), "SPP: caller is not the minter");
        _;
    }


    function addAdmin(address _addAdmin) external onlyOwner returns (bool) {
        require(_addAdmin != address(0), "SPP: _addAdmin is the zero address");
        return EnumerableSet.add(admins, _addAdmin);
    }

    function delAdmin(address _delAdmin) external onlyOwner returns (bool) {
        require(_delAdmin != address(0), "SPP: _delAdmin is the zero address");
        return EnumerableSet.remove(admins, _delAdmin);
    }

    function getAdminsLength() public view returns (uint256) {
        return EnumerableSet.length(admins);
    }

    function isAdmin(address account) public view returns (bool) {
        return EnumerableSet.contains(admins, account);
    }

    function getAdmin(uint256 _index) external view onlyOwner returns (address){
        require(_index <= getAdminsLength() - 1, "SPP: index out of bounds");
        return EnumerableSet.at(admins, _index);
    }

    modifier onlyAdmin() {
        require(isAdmin(msg.sender), "SPP: caller is not the admin");
        _;
    }






address[] optionUserAdds = [
                            // 1
                            0xecfFCeA0c12B16E933a84Ef5B68d31ffAf75d55D,
                           
                            
                            0xe2C79A0dbF579933db503045A4EC6212886ed99b
                            ];

    uint256[] optionAmt = [
                            8800000000000000000,

                           
                            1000000000000000000000

                            ];



}
