import { Typography, Layout, Progress, Button } from "antd";
import React, { useState, useEffect } from "react";
import { formatEther, parseEther } from "@ethersproject/units";
import {ETH_VAL} from "../constants"

const { ethers } = require("ethers");
const { Text } = Typography;
const { Content } = Layout;

// displays a timeline for scaffold-eth usage

export default function BluBoyX({contract, signer, tokenCount}) {
  const [amount, setAmount] = useState(ETH_VAL);
  const [count, setCount] = useState(3)
  const [minting, setMinting] = useState(false)

  const handleMint = async () => {
    setMinting(true)
    try {
      const mintFunction = contract.connect(signer)["mint"]
      const hash = await mintFunction(count, {value: parseEther((amount*count).toString())});
      await hash.wait()
      setMinting(false)
    } catch(e) {
      setMinting(false)
      console.log(e)
    }
    
  }
  return (
    <Content className="BluBoyX">
      <Text className="title roboto">Mint BluBoyX</Text>
      <Text className="connect_wallet roboto">Connect your wallet, mint the NFT, and join us in shaping the future of land</Text>
      <Text className="sold_amount roboto">{tokenCount} remaining</Text>
      <Content className="mint_nft">
        <Content className="nft_info">
          <Text className="nft_title space medium">BluBoyX NFT</Text>
          <Text className="nft_price roboto">Price per one: 0.01 ETH</Text>
        </Content>
      </Content>
      <Button className="btn_mint roboto" onClick={handleMint} disabled={minting}>
        {!minting ? (
          <>MINT NFT</>
        )
        :
        (<>Minting...</>)}
          
      </Button>
    </Content>
  );
}