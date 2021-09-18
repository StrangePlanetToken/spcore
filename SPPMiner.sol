// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "./PriceLibrary.sol";
import "./ReentrancyGuard.sol";
import "./SPMinerDefine.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./Ownable.sol";
import "./IERC20.sol";
import "./ISPPool.sol";


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


contract SPPMiner is ReentrancyGuard, SPMinerDefine, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public sppt; 
    ISPPool public sppool;


    address public constant dead = 0x000000000000000000000000000000000000dEaD;
    address public feeOwner;
    address public primaryAddr;


    struct user {
        uint256 id;
        uint256 option;
        address referrer;
        uint256 invitee;        // effective
        uint256 lastupdateblock;        
    }

    
    mapping(address => address[]) public mychilders;
    mapping(address => user) public users;
    mapping(uint256 => address) public index2User;
    uint256 public userCount = 0;       

    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private pools;

    event Register(address indexed _userAddr, address indexed _referrer);   
    event Option(address indexed _userAddr, uint256 _option); 

    uint256[10] rewardRate = [5000000000, 2500000000, 1250000000, 625000000, 312500000, 
                            156250000, 78125000, 39062500, 19531250, 9765625];              // 1e-10

    constructor ( address _feeOwner, address _primaryAddr) public {
        feeOwner = _feeOwner;
        primaryAddr = _primaryAddr;
        userCount = userCount.add(1);
        users[primaryAddr].id = userCount;
    }


    /**
     * user register
     */
    function register(address _referrer) public {
        require(!Address.isContract(msg.sender), "SPPM: the address is contract address ");
        require(!isExists(msg.sender), "SPPM: user exists");
        require(isExists(_referrer), "SPPM: referrer not exists");
        user storage regUser = users[msg.sender];
        userCount = userCount.add(1);
        regUser.id = userCount;
        index2User[userCount] = msg.sender;
        regUser.referrer = _referrer;

        mychilders[_referrer].push(msg.sender);
        sppool.addUser(msg.sender);

        emit Register(msg.sender, _referrer);
    }


    function addInvitee(address _userAddr) external onlyPool {
        address preAddr = users[_userAddr].referrer;
        users[preAddr].invitee = users[preAddr].invitee.add(1);
    }


    function subInvitee(address _userAddr) external onlyPool {
        address preAddr = users[_userAddr].referrer;
        users[preAddr].invitee = users[preAddr].invitee.sub(1);
    }


    function referReward(address _userAddr, uint256 _hashrate) external onlyPool {
        address preAddr = users[_userAddr].referrer;
        for(uint256 i = 0; i < 10; i++) {
            if(preAddr == address(0)) {
                break;
            }
            if(users[preAddr].invitee <= i+1) {       
                continue;
            }
            sppt.mint(preAddr, _hashrate.mul(rewardRate[i]).div(1e10));
            
            preAddr = users[preAddr].referrer;
        }
    }

    function setSppt(IERC20 _sppt) public onlyOwner { 
        sppt = _sppt;
    }

    function setSPPool(address addr) public onlyOwner { 
        sppool = ISPPool(addr);
    }


    function addPool(address _add) external onlyOwner returns (bool) {
        require(_add != address(0), "SPP: _add is the zero address");
        return EnumerableSet.add(pools, _add);
    }

    function delPool(address _del) external onlyOwner returns (bool) {
        require(_del != address(0), "SPP: _del is the zero address");
        return EnumerableSet.remove(pools, _del);
    }

    function getPoolsLength() public view returns (uint256) {
        return EnumerableSet.length(pools);
    }

    function isPool(address account) public view returns (bool) {
        return EnumerableSet.contains(pools, account);
    }

    function getPool(uint256 _index) external view onlyOwner returns (address){
        require(_index <= getPoolsLength() - 1, "SPP: index out of bounds");
        return EnumerableSet.at(pools, _index);
    }

    modifier onlyPool() {
        require(isPool(msg.sender), "SPP: caller is not the pool");
        _;
    }


    /**
    * insert the option user info 
     */
    function initOptionUserId() public onlyOwner{
        uint256 size = optionUserAdds.length;
        for(uint i=0; i<size; i++){
            userCount = userCount.add(1);
            users[optionUserAdds[i]].id = userCount;
        }
    }

    function initOptionUserOption() public onlyOwner{
        uint256 size = optionUserAdds.length;
        for(uint i=0; i<size; i++){
            users[optionUserAdds[i]].option = optionAmt[i];
        }
    }

    function initOptionUserReferrer() public onlyOwner{
        uint256 size = optionUserAdds.length;
        for(uint i=0; i<size; i++){
            users[optionUserAdds[i]].referrer = optionReferrer[i];
        }
    }

    function initOptionUserChilders() public onlyOwner{
        uint256 size = optionUserAdds.length;
        for(uint i=0; i<size; i++){
            mychilders[optionReferrer[i]].push(optionUserAdds[i]);
        }
    }

    
    function isExists(address _userAddr) view public returns (bool) {
        return users[_userAddr].id != 0;
    }


    function getMyChilders(address _userAddr) public view returns (address[] memory)
    {
        return mychilders[_userAddr];
    }

    
    function setFeeOwner (address _userAddr) public onlyOwner {
        require(!Address.isContract(msg.sender), "SPPM: the address is contract address ");
        feeOwner = _userAddr;
    }

    address[] optionUserAdds = [
                            // 1
                           
                           
                            0xe2C79A0dbF579933db503045A4EC6212886ed99b
                            ];

    uint256[] optionAmt = [
                           
                            1000000000000000000000

                            ];

    address[] optionReferrer = [
                           
                            0x9d81AC0BA72fC1B10aC30D12a14016012EA4E527

                            ];

}