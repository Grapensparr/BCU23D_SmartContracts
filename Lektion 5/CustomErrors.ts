import { expect } from "chai";
import hre from "hardhat";

describe("CustomErrors", function() {
    async function deployCustomErrorsFixture() {
        const [owner, notOwner] = await hre.ethers.getSigners();

        const CustomErrors = await hre.ethers.getContractFactory("CustomErrors");
        const customErrors = await CustomErrors.deploy();

        return { customErrors, owner, notOwner };
    }

    describe("Deployment", function() {
        it("Should set the correct owner", async function() {
            const { customErrors, owner } = await deployCustomErrorsFixture();

            expect(await customErrors.owner()).to.equal(owner.address);
            console.log(owner.address);
        });
    });

    describe("Test of setNumber function", function() {
        it("Should allow the owner to set a valid number", async function() {
            const { customErrors, owner } = await deployCustomErrorsFixture();
            const validNumber = 12;
            const lowNumber = 5;

            await customErrors.connect(owner).setNumber(validNumber);

            expect(await customErrors.number()).to.equal(validNumber);

            await expect(
                customErrors.connect(owner).setNumber(lowNumber)
            ).to.be.revertedWithCustomError(customErrors, "TooLow").withArgs(lowNumber, 10);

            expect(await customErrors.number()).to.equal(validNumber);
        });

        it("Should revert with NotOwner error, if called by nonOwner", async function() {
            const { customErrors, notOwner } = await deployCustomErrorsFixture();
            const validNumber = 12;

            await expect(
                customErrors.connect(notOwner).setNumber(validNumber)
            ).to.be.revertedWithCustomError(customErrors, "NotOwner").withArgs(notOwner.address);
        });

        it("Should revert with TooLow error if the number is less than 10", async function() {
            const { customErrors, owner } = await deployCustomErrorsFixture();
            const lowNumber = 5;

            await expect(
                customErrors.connect(owner).setNumber(lowNumber)
            ).to.be.revertedWithCustomError(customErrors, "TooLow").withArgs(lowNumber, 10);
        });

        it("Should not update the number if the transaction reverts", async function() {
            const { customErrors, owner } = await deployCustomErrorsFixture();
            const lowNumber = 5;

            await expect(
                customErrors.connect(owner).setNumber(lowNumber)
            ).to.be.revertedWithCustomError(customErrors, "TooLow").withArgs(lowNumber, 10);

            expect(await customErrors.number()).to.equal(0);
        })
    });
})
