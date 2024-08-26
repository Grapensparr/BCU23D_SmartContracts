import { expect } from "chai";
import hre from "hardhat";

describe("HelloWorld", function() {
    async function deployHelloWorldFixture() {
        const initialMessage = "Hello world!";

        const HelloWorld = await hre.ethers.getContractFactory("HelloWorld");
        const helloWorld = await HelloWorld.deploy(initialMessage);

        return { helloWorld, initialMessage };
    }

    describe("Deployment", function() {
        it("Should set the correct initial message", async function() {
            const { helloWorld, initialMessage } = await deployHelloWorldFixture();

            expect(await helloWorld.message()).to.equal(initialMessage);
            console.log("Initial message: ", initialMessage);
        });
    });

    describe("Message update", function() {
        it("Should update the message", async function() {
            const { helloWorld } = await deployHelloWorldFixture();
            const newMessage = "Hello BCU23D!";

            await helloWorld.setMessage(newMessage);

            expect(await helloWorld.message()).to.equal(newMessage);
        });

        it("Should allow multiple updates", async function() {
            const { helloWorld } = await deployHelloWorldFixture();
            const firstMessage = "First message";
            const secondMessage = "Second message";

            await helloWorld.setMessage(firstMessage);
            expect(await helloWorld.message()).to.equal(firstMessage);

            await helloWorld.setMessage(secondMessage);
            expect(await helloWorld.message()).to.equal(secondMessage);
        });
    });

    describe("Retrieve message", function() {
        it("Should return the correct message using getMessage", async function() {
            const { helloWorld, initialMessage } = await deployHelloWorldFixture();
        
            expect(await helloWorld.getMessage()).to.equal(initialMessage);
    
            const newMessage = "BCU23D";
            await helloWorld.setMessage(newMessage);
            expect(await helloWorld.getMessage()).to.equal(newMessage);
        });
    });
})
