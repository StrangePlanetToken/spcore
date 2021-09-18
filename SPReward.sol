// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;
import "./Ownable.sol";
import "./SafeERC20.sol";
import "./ISPPMiner.sol";
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


contract SPReward is Ownable{
    using SafeMath for uint256;

    IERC20 public spt;
    uint256 public spttotal;
    IERC20 public spptoken; 
    ISPPMiner public sppminer; 
    ISPPool public sppool;

    EnumerableSet.AddressSet private admins;

    uint256 public constant sptPerDay = 4112.5e18;  
    uint256 public constant totalHashrate = 100353.65625e18;  

    address[] public rewardUsers;
    uint256[] public rewards;
    uint256[] public sppt;


    // 1. compute the reward
    function compute() public onlyAdmin{
         for(uint256 i=0; i < addresslist.length; i++) {
            address a = addresslist[i];
            address[] memory childers =  sppminer.getMyChilders(a);
            uint256 depositUsdt = 0;
            uint256 depositTime = now; 
            
                                  
            for(uint256 j=0; j<childers.length; j++) {
                address c = childers[j];
                uint256 depositU = sppool.getDepositInfoUsdt(c);
                uint256 depositT = sppool.getDepositInfoTime(c);

                if(depositU > 1e10){
                    if(depositT < depositTime){
                        depositUsdt = depositU;
                        depositTime = depositT;
                    }
                }  
            }
            if(depositUsdt > 1e10){
                rewardUsers.push(a);
                uint256 hashrate = depositUsdt.div(8).mul(10).div(2);
                sppt.push( hashrate );
            }
        }
    }

    // 2. sppt
    function spptReward() public onlyAdmin {
        for(uint256 i=0; i<rewardUsers.length; i++){
            spptoken.mint(rewardUsers[i], sppt[i]);
        }
        
    }


    // 3.1 
    function sptTotal() public onlyAdmin returns(uint256 amt) {
        uint256 res = 0;
        for(uint256 i=0; i<rewards.length; i++){
            res += rewards[i];
        }
        spttotal = res;
        return res;
    }


    // 3.2 reward
    function reward() public onlyAdmin {
        for(uint256 i=0; i<rewardUsers.length; i++){
            spt.transfer(rewardUsers[i], rewards[i]);
        }
    }


  

    function setSpt(IERC20 _spt) public onlyOwner {
        spt = _spt;
    }


    function setSppToken(IERC20 _spptoken) public onlyOwner {
        spptoken = _spptoken;
    }

    function setSPPool(ISPPool _sppool) public onlyOwner {
        sppool = _sppool;
    }


    
    function setSppMiner(ISPPMiner _sppminer) public onlyOwner {
        sppminer = _sppminer;
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


   address[] public addresslist = [

0xE952514c9754eb3b387C98D3149199028Af5727D

   ];

}