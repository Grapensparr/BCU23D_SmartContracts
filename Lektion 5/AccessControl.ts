import { expect } from "chai";
import hre from "hardhat";

describe("AccessControl", function() {
    async function deployAccessControlFixture(){
        const [owner, admin, supporter, member, nonAdmin] = await hre.ethers.getSigners();

        const AccessControl = await hre.ethers.getContractFactory("AccessControl");
        const accessControl = await AccessControl.deploy();

        return { accessControl, owner, admin, supporter, member, nonAdmin }
    }

    describe("Deployment", function() {
        it("Should set the deployer as an admin", async function() {
            const { accessControl, owner } = await deployAccessControlFixture();

            expect(await accessControl.admins(owner.address)).to.be.true;
        });
    });

    describe("Assign role", function() {
        it("Should allow an admin to assign admin role", async function() {
            const { accessControl, admin } = await deployAccessControlFixture();

            await accessControl.assignAdminRole(admin.address);

            expect(await accessControl.admins(admin.address)).to.be.true;
        });

        it("Should allow and admin to assign supporter role", async function() {
            const { accessControl, supporter } = await deployAccessControlFixture();

            await accessControl.assignSpecificRole(supporter.address, "Supporter");

            expect(await accessControl.supporters(supporter.address)).to.be.true;
        });

        it("Should allow and admin to assign member role", async function() {
            const { accessControl, member } = await deployAccessControlFixture();

            await accessControl.assignSpecificRole(member.address, "Member");

            expect(await accessControl.members(member.address)).to.be.true;
        });

        it("Should emit RoleAssigned event when role is assigned", async function() {
            const { accessControl, supporter } = await deployAccessControlFixture();

            await expect(accessControl.assignSpecificRole(supporter.address, "Supporter"))
            .to.emit(accessControl, "RoleAssigned")
            .withArgs(supporter.address, "Supporter");
        });

        it("Should revert if non-admin tries to assign role", async function() {
            const { accessControl, supporter, nonAdmin } = await deployAccessControlFixture();

            await expect(
                accessControl.connect(nonAdmin).assignSpecificRole(supporter.address, "Supporter")
            ).to.be.revertedWith("You are not an admin and cannot call this function");
        });

        it("Should revert if an invalid role is assigned", async function() {
            const { accessControl, supporter } = await deployAccessControlFixture();

            await expect(
                accessControl.assignSpecificRole(supporter.address, "Invalid role")
            ).to.be.revertedWith("Invalid role. Try again!");
        });
    });
})
