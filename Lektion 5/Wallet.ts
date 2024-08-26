import { expect } from "chai";
import hre, { ethers } from "hardhat";

describe("Wallet", function() {
    async function deployWalletFixture() {
        const [owner] = await ethers.getSigners();

        const Wallet = await ethers.getContractFactory("Wallet");
        const wallet = await Wallet.deploy();

        const ReentrancyAttack = await ethers.getContractFactory("ReentrancyAttack");
        const reentrancyAttack = await ReentrancyAttack.deploy(wallet.getAddress());

        return { wallet, reentrancyAttack, owner };
    }

    describe("Deposits", function() {
        it("Should accept deposits and emit DepositMade event", async function() {
            const { wallet, owner } = await deployWalletFixture();
            const depositAmount = ethers.parseEther("1.0");

            await expect(
                wallet.deposit({ value: depositAmount })
            ).to.emit(wallet, "DepositMade")
            .withArgs(owner.address, depositAmount);

            expect(await wallet.contractBalance()).to.equal(depositAmount);
        });

        it("SHould accept deposits via receive fuction", async function() {
            const { wallet, owner } = await deployWalletFixture();
            const depositAmount = ethers.parseEther("1.0");

            await expect(
                owner.sendTransaction({ to: wallet.getAddress(), value: depositAmount })
            ).to.emit(wallet, "DepositMade")
            .withArgs(owner.address, depositAmount);

            const contractBalance = await wallet.contractBalance();
            expect(contractBalance).to.equal(depositAmount);
        });
    });

    describe("Withdrawls", function() {
        it("Should allow valid withdrawl and emit WithdrawalMade event", async function() {
            const { wallet, owner } = await deployWalletFixture();
            const depositAmount = ethers.parseEther("1.0");

            await wallet.deposit({ value: depositAmount });

            expect(await wallet.contractBalance()).to.equal(depositAmount);

            await expect(
                wallet.withdraw(depositAmount)
            ).to.emit(wallet, "WithdrawalMade")
            .withArgs(owner.address, depositAmount);

            expect(await wallet.contractBalance()).to.equal(0);
        });
    });

    describe("Fallback", function() {
        it("Should revert with the correct error when fallback is called", async function() {
            const { wallet, owner } = await deployWalletFixture();

            await expect(
                owner.sendTransaction({ to: wallet.getAddress(), data: "0x1234" })
            ).to.be.revertedWith("Fallback function. Call a function that exists!");
        });
    });

    describe("Reentrancy", function() {
        it("Should prevent reentrancy attack", async function() {
            const { wallet, reentrancyAttack } = await deployWalletFixture();

            await wallet.deposit({ value: ethers.parseEther("2.0")});

            await expect(
                reentrancyAttack.attack({ value: ethers.parseEther("1.0")})
            ).to.be.rejectedWith("Stop making reentrancy calls! Please hold.");

            expect(await wallet.contractBalance()).to.equal(ethers.parseEther("2.0"));
        });
    });
})
