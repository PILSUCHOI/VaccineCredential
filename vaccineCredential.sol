    //SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.10;

contract vaccineCredential {
    address private issuerAddress;                  // 컨트랙트 실행자 = 발급자
    uint256 private idCount;                        // 발급 횟수
    mapping(uint8 => string) private vaccinetype;   // 백신 종류

    struct Credential{          // 증명서에 담기는 검증 요소들
        uint256 id;             // 식별 번호
        address issuer;         // 발급자
        uint8 vaccinetype;     // 백신 종류
        string date;            // 날짜
    }

    // 발급시 저장될 위치
    mapping(address => Credential) private credentials ; // Credential 발행시 지칭될 변수
    mapping(address => Credential) private Personalmobile ; // Credential 발행시 저장될 장소1
    mapping(address => Credential) public StorageIPFS ; // Credential 발행시 저장될 장소2 ( IPFS 저장소 : 분산형 파일 시스템 저장소 )
    

    constructor() {                         
        issuerAddress = msg.sender;         // 호출자 주소를 가르키는 msg.sender
        idCount = 1;
        vaccinetype[0] = "Pfizer" ;
        vaccinetype[1] = "Moderna" ;
        vaccinetype[2] = "AstraZeneca" ;   
    }

    // Credential 발급 
    function issueCredential(address _receiverAddress, uint8 _vaccinetype, string calldata _date) public returns(bool){    // 인자 3개를 받아 새로운 증명서를 생성한다
        
        require(issuerAddress == msg.sender, "Not Issuer");
                Credential storage credential = credentials[_receiverAddress];
        
        require(credential.id == 0);
        credential.id = idCount;
        credential.issuer = msg.sender;
        credential.vaccinetype = _vaccinetype;
        credential.date = _date;

        idCount += 1;

        registerCredential(_receiverAddress);

        return true;
    }

    

    // 발급된 Credential 저장소1 ( 핸드폰 ) 
    function getCredential(address _receiverAddress) public returns(bool) {

        Credential memory mobile = credentials[_receiverAddress];
        Personalmobile[_receiverAddress] = mobile ;  
        return true;
    }


    // 발급된 Credential 저장소2 ( 분산형 시스템 저장소 ) 
    function registerCredential ( address _receiverAddress) internal {
        Credential memory IPFS = credentials[_receiverAddress];
        StorageIPFS[_receiverAddress] = IPFS ; // 저장
    }


 // Credential 판별 위한 해쉬 함수 작성
 function hash(uint256 _id, address _issuer, uint8 _vaccineType, string memory _date) pure internal returns(bytes32) {
     return keccak256(abi.encodePacked(_id,_issuer,_vaccineType,_date));
}

   
   // verify - 모바일 발급한 Credential과 IPFS에 있는 것을 대조해서 판별 
 function verifyCredential(address _receiverAddress) view public returns(bool) {

    Credential memory phoneCre = Personalmobile[_receiverAddress];
    Credential memory ipfsCre = StorageIPFS[_receiverAddress] ;      

    
    bytes32 phone = hash(phoneCre.id, phoneCre.issuer, phoneCre.vaccinetype, phoneCre.date);
    bytes32 ipfs = hash(ipfsCre.id, ipfsCre.issuer, ipfsCre.vaccinetype, ipfsCre.date);

    if(phone ==ipfs){
            return true;
        }else return false;

    }

}