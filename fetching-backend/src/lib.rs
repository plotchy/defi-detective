pub mod configuration;
pub mod node_watcher;
pub mod bytecode_analyzer;

use regex::bytes;
use once_cell::sync::Lazy;


const RE_ERC20_SELECTORS_BYTES_SET: Lazy<bytes::RegexSet> = Lazy::new( || {
    bytes::RegexSetBuilder::new(&[
        r"\x63\x06\xfd\xde\x03", // push4 name()
        r"\x63\x95\xd8\x9b\x41", // push4 symbol()
        r"\x63\x31\x3c\xe5\x67", // push4 decimals()
        r"\x63\x18\x16\x0d\xdd", // push4 totalSupply()
        r"\x63\x70\xa0\x82\x31", // push4 balanceOf(address)
        r"\x63\xdd\x62\xed\x3e", // push4 allowance(address,address)
        r"\x63\x09\x5e\xa7\xb3", // push4 approve(address,uint256)
        r"\x63\xa9\x05\x9c\xbb", // push4 transfer(address,uint256)
        r"\x63\x23\xb8\x72\xdd", // push4 transferFrom(address,address,uint256)
    ])
    .unicode(false)
    .build().unwrap()
});

const RE_ERC20_SELECTORS_STRING_SET: Lazy<regex::RegexSet> = Lazy::new( || {
    regex::RegexSetBuilder::new(&[
        r"6306fdde03", // push4 name()
        r"6395d89b41", // push4 symbol()
        r"63313ce567", // push4 decimals()
        r"6318160ddd", // push4 totalSupply()
        r"6370a08231", // push4 balanceOf(address)
        r"63dd62ed3e", // push4 allowance(address,address)
        r"63095ea7b3", // push4 approve(address,uint256)
        r"63a9059cbb", // push4 transfer(address,uint256)
        r"6323b872dd", // push4 transferFrom(address,address,uint256)
    ])
    .unicode(false)
    .build().unwrap()
});