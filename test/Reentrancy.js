const { expect } = require('chai')
const { ethers } = require('hardhat')

describe('Deploy contracts', function () {
  let deployer, user, attacker
  let bank, attackerContract

  beforeEach(async function () {
    [deployer, user, attacker] = await ethers.getSigners()

    const BankFactory = await ethers.getContractFactory('Bank', deployer)
    bank = await BankFactory.deploy()

    await bank.deposit({ value: ethers.utils.parseEther('100') })
    await bank.connect(user).deposit({ value: ethers.utils.parseEther('50') })

    const AttackerFactory = await ethers.getContractFactory('Attacker', attacker)
    attackerContract = await AttackerFactory.deploy(bank.address)
  })

  describe('Test deposit and withdraw of Bank contract', function () {
    it('Should accept deposits', async function () {
      const deployerBalance = await bank.balanceOf(deployer.address)
      expect(deployerBalance).to.eq(ethers.utils.parseEther('100'))

      const userBalance = await bank.balanceOf(user.address)
      expect(userBalance).to.eq(ethers.utils.parseEther('50'))
    })

    it('Should accept withdrawals', async function () {
      await bank.withdraw()

      const deployerBalance = await bank.balanceOf(deployer.address)
      const userBalance = await bank.balanceOf(user.address)

      expect(deployerBalance).to.eq(0)
      expect(userBalance).to.eq(ethers.utils.parseEther('50'))
    })

    it('Allows attacker to drain funds form #withdraw()', async function () {
      console.log('*** Before ***')
      console.log(`Bank's balance: ${ethers.utils.formatEther(await ethers.provider.getBalance(bank.address)).toString()}`)
      console.log(`Attacker's balance: ${ethers.utils.formatEther(await ethers.provider.getBalance(attacker.address)).toString()}`)

      await attackerContract.attack({ value: ethers.utils.parseEther('10') })

      console.log('*** After ***')
      console.log(`Bank's balance: ${ethers.utils.formatEther(await ethers.provider.getBalance(bank.address)).toString()}`)
      console.log(`Attackers's balance: ${ethers.utils.formatEther(await ethers.provider.getBalance(attacker.address)).toString()}`)

      expect(await ethers.provider.getBalance(bank.address)).to.eq(0)
    })

  })
})
