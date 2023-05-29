
// File: contracts/IERC721.sol



pragma solidity ^0.8.4;

interface IERC721 {
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) external payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    function approve(address _approved, uint256 _tokenId) external payable;
    function setApprovalForAll(address _operator, bool _approved) external;
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

}

// File: contracts/ERC721.sol



pragma solidity ^0.8.4;


contract ERC721 is IERC721 {
    string public _name;
    string public _symbol;

    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenToOwner;
    mapping(uint256 => address) private _tokenToApproved;

    mapping(address => mapping(address => bool)) private _approvedAddresses;

    constructor(string memory name, string memory symbol) {
        _name = name;
        _symbol = symbol;
    }

    function balanceOf(address _owner) external view returns (uint256) {
        return _balances[_owner];
    }

    function ownerOf(uint256 _tokenId) external view returns (address) {
        address owner = _tokenToOwner[_tokenId];
        require(owner != address(0), "Invalid token");
        return owner;
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory data
    ) public payable {
        require(_isOwnerOrApprovedAddress(msg.sender, _tokenId), "Caller is not owner or approved");
        require(_to != address(0), "Can not send to zero address");

        _transfer(_from, _to, _tokenId);

        // require(_checkOnERC721Received(_from, _to, _tokenId, data), "Transfer to non ERC721Receiver");
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal {
        require(_isOwnerOrApprovedAddress(msg.sender, _tokenId), "Caller is not owner or approved");
        require(_to != address(0), "Can not send to zero address");

        _tokenToOwner[_tokenId] = _to;

        _balances[_from]--;
        _balances[_to]++;

        emit Transfer(_from, _to, _tokenId);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        _approvedAddresses[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function getApproved(uint256 _tokenId) external view returns (address) {
        return _tokenToApproved[_tokenId];
    }

    function approve(address _approved, uint256 _tokenId) external payable {
        require(msg.sender == _tokenToOwner[_tokenId], "Not owner");
        _tokenToApproved[_tokenId] = _approved;

        emit Approval(msg.sender, _approved, _tokenId);
    }

    function isApprovedForAll(address _owner, address _operator) public view override returns (bool) {
        return _approvedAddresses[_owner][_operator];
    }

    function _isOwnerOrApprovedAddress(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = _tokenToOwner[tokenId];
        return (spender == owner || isApprovedForAll(spender, owner));
    }
}
