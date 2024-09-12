const alchemyKey = process.env.REACT_APP_ALCHEMY_KEY;
const { createAlchemyWeb3 } = require('@alch/alchemy-web3');
const web3 = createAlchemyWeb3(alchemyKey); 

const contractABI = require('../contract-abi.json');
const contractAddress = process.env.REACT_APP_CONTRACT;

const votingContract = new web3.eth.Contract(
    contractABI,
    contractAddress
);

export const connectWallet = async () => {
    if (window.ethereum) {
        try {
            const addressArray = await window.ethereum.request({
                method: 'eth_requestAccounts',
            });

            return {
                address: addressArray[0],
                status: ''
            }
        } catch (err) {
            return {
                address: '',
                status: err.message
            }
        }
    } else {
        return {
            address: '',
            status: (
                <span>
                    Want to use this application? <br/>
                    <a target='blank' href='https://metamask.io/download.html'>
                        Install MetaMask for your browser!
                    </a>
                </span>
            )
        };
    }
};

export const getCurrentWalletConnected = async () => {
    if (window.ethereum) {
        try {
            const accounts = await window.ethereum.request({
                method: 'eth_accounts'
            });

            if (accounts.length > 0) {
                return {
                    address: accounts[0],
                    status: ''
                }
            } else {
                return {
                    address: '',
                    status: 'Connect your wallet using the top right button'
                }
            }
        } catch (err) {
            return {
                address: '',
                status: err.message
            }
        }
    } else {
        return {
            address: '',
            status: (
                <span>
                    Want to use this application? <br/>
                    <a target='blank' href='https://metamask.io/download.html'>
                        Install MetaMask for your browser!
                    </a>
                </span>
            )
        };
    }
};

export const checkIfVoted = async (address) => {
    const voted = await votingContract.methods.hasVoted(address).call();
    return voted;
};

export const walletListener = (setWalletAddress, checkIfVoted, setHasVoted, setStatus) => {
    if (window.ethereum) {
        window.ethereum.on('accountsChanged', async (accounts) => {
            if (accounts.length > 0) {
                setWalletAddress(accounts[0]);
                const voted = await checkIfVoted(accounts[0]);
                setHasVoted(voted);
                setStatus('');
            } else {
                setWalletAddress('');
                setHasVoted(false);
                setStatus('Connect your wallet using the top right button!')
            }
        });
    }
};

export const startVoting = async (walletAddress) => {
    try {
        await votingContract.methods.startVoting().send({
            from: walletAddress
        });
        return {
            status: 'The voting has started'
        };
    } catch (err) {
        return {
            status: 'Error starting voting: ' + err.message
        };
    }
}

export const getVotingState = async () => {
    const state = await votingContract.methods.votingState().call();
    return state;
}

export const mapVotingState = (state) => {
    switch (parseInt(state)) {
        case 0:
            return 'NotStarted';
        case 1:
            return 'Ongoing';
        case 2:
            return 'Finished';
        default:
            return 'Unknown state';
    }
};

export const loadCandidates = async () => {
    const candidateList = [];
    for (let i = 0; i < 3; i++) {
        const candidate = await votingContract.methods.candidates(i).call();
        candidateList.push(candidate);
    }

    return candidateList;
}

export const voteForCandidate = async (walletAddress, candidateName) => {
    if (!window.ethereum || !walletAddress) {
        return {
            status: 'You must connect your wallet in order to cast a vote'
        };
    }

    try {
        const transactionParameters = {
            to: contractAddress,
            from: walletAddress,
            data: votingContract.methods.vote(candidateName).encodeABI()
        };

        const txHash = await window.ethereum.request({
            method: 'eth_sendTransaction',
            params: [transactionParameters]
        });

        return {
            status: (
                <span>
                    <a target='blank' href={`https://sepolia.etherscan.io/tx/${txHash}`}>
                        View the status of your transaction on Etherscan!
                    </a>
                    <br/>
                    Your vote is being processed. Once the transaction is verified, the vote will be counted.
                </span>
            ),
            txHash
        }
    } catch (err) {
        return {
            status: 'Error when casting vote: ' + err.message
        };
    }
};

export const waitForTransactionConfirmation = async (txHash, setHasVoted, loadCandidates) => {
    try {
        let receipt = null;
        while (receipt === null) {
            receipt = await web3.eth.getTransactionReceipt(txHash);
        }

        if (receipt && receipt.status) {
            setHasVoted(true);
            const updateCandidates = await loadCandidates();
            return updateCandidates
        }
    } catch (err) {
        console.error('Error confirming transaction: ', err);
    }
}

export const eventListeners = (setStatus, setVotingState, setWinner, loadCandidates) => {
    votingContract.events.VotingStarted({}, (err) => {
        if (err) {
            setStatus(err.message);
        } else {
            setVotingState('Ongoing');
        }
    });

    votingContract.events.VoteCast({}, async (err, data) => {
        if (err) {
            setStatus(err.message);
        } else {
            setStatus(`Your vote for ${data.returnValues[0]} has been successfully cast!`);
        }
    })

    votingContract.events.VotingFinished({}, (err, data) => {
        if (err) {
            setStatus(err.message)
        } else {
            setVotingState('Finished');
            setWinner(data.returnValues.winner);
        }
    });
}

export const getWinner = async () => {
    const winner = await votingContract.methods.winner().call();
    return winner;
}