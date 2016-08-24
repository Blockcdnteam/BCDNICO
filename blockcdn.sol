/*
This file is contract of the BCDN.

The BCDN is free software: you can redistribute it and/or modify
it under the terms of the GNU lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

The BCDN is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU lesser General Public License for more details.

You should have received a copy of the GNU lesser General Public License
along with the BCDN.  If not, see <http://www.gnu.org/licenses/>.
*/
contract blockcdn {
    mapping (address => uint256) balances;
    address public owner;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint256 public fundedSupply;
    uint256 public minFundedValue;
    bool public isFunded;
    uint256 closetime;
    
     /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    function blockcdn(
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        uint256 _closetime,
		uint256 _minValue
        ) { 
        owner = msg.sender;                                  // Set owner of the contract
        name = _tokenName;                                   // Set the name for display purposes
        symbol = _tokenSymbol;                               // Set the symbol for display purposes
        decimals = _decimalUnits;                            // Amount of decimals for display purposes
        closetime = _closetime;                              // Set fund closing time
		minFundedValue = _minValue;                          // Set minimum funing goal
		isFunded = false;                                    // Initialize fund succeed flag 
    }
    
    /*query BCDN balance*/
    function balanceOf( address _owner) constant returns (uint256 balance)
    {
       return balances[_owner];
    }
    
    /*send ethereum and get BCDN*/
    function buyBlockCDN() returns (bool success){
        if(now > closetime) throw; 
        uint256 token = 0;
        if(closetime - 2 weeks > now) {
             token = msg.value;
        }else {
            uint day = (now - (closetime - 2 weeks))/(2 days) + 1;
            token = msg.value;
            while( day > 0) {
                token  =   token * 95 / 100 ;    
                day -= 1;
            }
        }
        
        balances[msg.sender] += token;
        fundedSupply += token;
        balances[owner] = fundedSupply /2;
        totalSupply =  balances[owner] + fundedSupply;
        if(fundedSupply > minFundedValue) {
            isFunded = true;
        }
        Transfer(this, msg.sender, token);    
        return true;
    }    
    
    /*refund 'msg.sender' in the case the Token Sale didn't reach ite minimum 
    funding goal*/
    function reFund() returns (bool success) {
        if(now > closetime) throw;
        msg.sender.send(balances[msg.sender]);
        fundedSupply -= balances[msg.sender];
        balances[owner] = fundedSupply /2;
        totalSupply =  balances[owner]  + fundedSupply;
        balances[msg.sender] = 0;
        Transfer(msg.sender, this, balances[msg.sender]); 
        return true;
        
    }
    
    /* Send coins */
    function transfer(address _to, uint256 _value) returns (bool success) {
        if(now < closetime)  throw;                                 //Closed fund allow transfer
        if (balances[msg.sender] < _value) throw;                   // Check if the sender has enough
        if (balances[_to] + _value < balances[_to]) throw;          // Check for overflows
        balances[msg.sender] -= _value;                             // Subtract from the sender
        balances[_to] += _value;                                    // Add the same to the recipient
        Transfer(msg.sender, _to, _value);                          // Notify anyone listening that this transfer took place
        return true;
    }
    
    /*send reward*/
    function sendRewardBlockCDN(address rewarder, uint256 value) returns (bool success) {
        if(msg.sender != owner) throw;
        if(now <= closetime) throw;
        if( balances[owner] < value) throw;
        balances[rewarder] += value;
        balances[owner] -= value;
        Transfer(owner, rewarder, value);    
        return true;
       
    }
    
    /*withDraw ethereum when closed fund*/
    function withDrawEth(uint256 value) returns (bool success) {
        if(now <= closetime ) throw;
        if(this.balance < value) throw;
        if(msg.sender != owner) throw;
        msg.sender.send(value);
            return true;
    }
}