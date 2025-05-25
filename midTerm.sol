// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Auction {

    address public owner;            // 관리자 A
    bool public isActive;           // 경매 진행 상태

    struct Bidder {
        string name;
        uint bidAmount;
    }

    mapping(address => Bidder) public bidders;

    address public highestBidder;
    uint public highestBid;

    constructor() {
        owner = msg.sender;         // 배포한 사람을 관리자(A)로 설정
        isActive = true;            // 경매 활성화
    }

    // 관리자 전용 제어자
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    // 입찰 함수 - B, C가 호출
    function placeBid(string memory _name) public payable {
        require(isActive, "Auction has ended.");
        require(msg.value > highestBid, "Your bid is too low.");

        // 이전 최고 입찰자 환불 처리
        if (highestBid > 0) {
            payable(highestBidder).transfer(highestBid);
        }

        // 새로운 입찰자 정보 저장
        bidders[msg.sender] = Bidder(_name, msg.value);
        highestBid = msg.value;
        highestBidder = msg.sender;
    }

    // 경매 종료 - 관리자만 실행
    function endAuction() public onlyOwner {
    require(isActive, "Auction is already ended.");
    isActive = false;
    // 최고 입찰 금액을 관리자에게 송금 (입찰 금액이 0보다 클 때만 송금)
    if (highestBid > 0) {
        payable(owner).transfer(highestBid);
    }
}

    // 최고 입찰자 정보 (이름 + 금액)
    function getHighestBidder() public view returns (string memory, uint) {
        Bidder memory bidder = bidders[highestBidder];
        return (bidder.name, bidder.bidAmount);
    }

    // 낙찰자 전체 정보 조회 (이름, 금액, 주소)
    function getWinnerInfo() public view returns (string memory, uint, address) {
        Bidder memory winner = bidders[highestBidder];
        return (winner.name, winner.bidAmount, highestBidder);
    }

    // 이더 수신용
    receive() external payable {}

    // fallback 처리 (선택 사항)
    fallback() external payable {}
}
