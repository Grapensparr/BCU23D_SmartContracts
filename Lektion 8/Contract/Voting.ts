import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const VotingModule = buildModule("VotingModule", (m) => {
    const candidates = ["Anna", "Pelle", "Sara"];
    const voting = m.contract("Voting", [candidates], {});

    return { voting };
});

export default VotingModule;