# Cyclic-Polynomial-Hash
A Nim implementation of a Cyclic Polynomial Hash, aka BuzHash. A Cyclic Polynomial hash is a type of Rolling hash which avoids
multiplication by using circular shifts and xoring. This implementation has type support for (int, uint8, uint16, uint32, and int64). For more information regarding Cyclic Polynomial hashing please refer to wiki's article on <a class="external reference" href="https://en.wikipedia.org/wiki/Rolling_hash#Cyclic_polynomial">Rolling Hash</a>

## Example Usage
```
import cyclichash, sequtils                                                   

var hf = newCyclicHash[Natural, char](5, 19) # Create a Cyclic with a 5 n-gram sliding window and 19 bit sized hash values
let input = "ABCDE"
  
hf.eat(input[0]) # A
hf.eat(input[1]) # B
hf.eat(input[2]) # C
hf.eat(input[3]) # D
echo "Hash value of ABCD is ", hf.hashValue
  
let charSeqFull = toSeq(input.items) # create a seq[char] out of input string "ABCDE"
let charSeqPart = charSeqFull[0 ..< 4] # slice input string to obtain "ABCD"
  
var trueAnswer = hf.hash(charSeqPart) # Check if hash value of "ABCD" is correct
assert trueAnswer == hf.hashValue
  
hf.eat(input[4]) # E
echo "Hash value of ABCDE is ", hf.hashValue
  
trueAnswer = hf.hash(charSeqFull) # Check if hash value of "ABCDE" is correct
assert trueAnswer == hf.hashValue
``` 
## Installation
Install <a class="external reference" href="https://nim-lang.org/install.html">Nim</a> for Windows or Unix by following the instructions in , or preferably by installing <a class="reference external" href="https://github.com/dom96/choosenim">choosenim</a>

Once ```choosenim``` is installed you can ```nimble install cyclic-polynomial-hash``` to pull the latest bipbuffer release and all its dependencies

## Documentation
Refer to the following documentation for a list of procedures and templates: <a class="external reference" href="https://marcazar.github.io/Cyclic-Polynomial-Hash/docs/cyclichash.html">Cyclic Hash</a> and <a class="external reference" href="https://marcazar.github.io/Cyclic-Polynomial-Hash/docs/characterhash.html">Character Hash</a>

## Credits
Special thanks for Dr. Daniel Lemire for his help and for replying to my inquires concerning his implementation of cyclic hash in c++ found <a class="reference external" href="https://github.com/lemire/rollinghashcpp">here</a> along with other handy rolling hash functions! 
