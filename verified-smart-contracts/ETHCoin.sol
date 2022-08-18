{"ERC20Standard.sol":{"content":"pragma solidity ^0.8.11;\n\nlibrary SafeMath {\n\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n        if (a == 0) {\n            return 0;\n        }\n\n        uint256 c = a * b;\n        require(c / a == b);\n\n        return c;\n    }\n\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b \u003e 0);\n        uint256 c = a / b;\n        \n\treturn c;\n    }\n\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b \u003c= a);\n        uint256 c = a - b;\n\n        return c;\n    }\n\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\n        uint256 c = a + b;\n        require(c \u003e= a);\n\n        return c;\n    }\n\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b != 0);\n        return a % b;\n    }\n}\n\ncontract ERC20Standard {\n\tusing SafeMath for uint256;\n\tuint public totalSupply;\n\t\n\tstring public name;\n\tuint8 public decimals;\n\tstring public symbol;\n\tstring public version;\n\t\n\tmapping (address =\u003e uint256) balances;\n\tmapping (address =\u003e mapping (address =\u003e uint)) allowed;\n\n\t//Fix for short address attack against ERC20\n\tmodifier onlyPayloadSize(uint size) {\n\t\tassert(msg.data.length == size + 4);\n\t\t_;\n\t} \n\n\tfunction balanceOf(address _owner) public view returns (uint balance) {\n\t\treturn balances[_owner];\n\t}\n\n\tfunction transfer(address _recipient, uint _value) public onlyPayloadSize(2*32) {\n\t    require(balances[msg.sender] \u003e= _value \u0026\u0026 _value \u003e 0);\n\t    balances[msg.sender] = balances[msg.sender].sub(_value);\n\t    balances[_recipient] = balances[_recipient].add(_value);\n\t    emit Transfer(msg.sender, _recipient, _value);        \n        }\n\n\tfunction transferFrom(address _from, address _to, uint _value) public {\n\t    require(balances[_from] \u003e= _value \u0026\u0026 allowed[_from][msg.sender] \u003e= _value \u0026\u0026 _value \u003e 0);\n            balances[_to] = balances[_to].add(_value);\n            balances[_from] = balances[_from].sub(_value);\n            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\n            emit Transfer(_from, _to, _value);\n        }\n\n\tfunction  approve(address _spender, uint _value) public {\n\t\tallowed[msg.sender][_spender] = _value;\n\t\temit Approval(msg.sender, _spender, _value);\n\t}\n\n\tfunction allowance(address _spender, address _owner) public view returns (uint balance) {\n\t\treturn allowed[_owner][_spender];\n\t}\n\n\t//Event which is triggered to log all transfers to this contract\u0027s event log\n\tevent Transfer(\n\t\taddress indexed _from,\n\t\taddress indexed _to,\n\t\tuint _value\n\t\t);\n\t\t\n\t//Event which is triggered whenever an owner approves a new allowance for a spender.\n\tevent Approval(\n\t\taddress indexed _owner,\n\t\taddress indexed _spender,\n\t\tuint _value\n\t\t);\n}\n"},"ETHCoinToken.sol":{"content":"pragma solidity ^0.8.11;\n\nimport \"./ERC20Standard.sol\";\n\ncontract ETHCoin is ERC20Standard {\n\tconstructor() public {\n\t\ttotalSupply = 1*100000000000000;\n\t\tname = \"ETH Coin\";\n\t\tdecimals = 6;\n\t\tsymbol = \"ETHCoin\";\n\t\tversion = \"1.0\";\n\t\tbalances[msg.sender] = totalSupply;\n\t}\n}"}}