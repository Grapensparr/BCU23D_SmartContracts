import { useEffect, useState } from 'react';
import { 
    checkIfVoted,
    connectWallet, 
    eventListeners, 
    getCurrentWalletConnected, 
    getVotingState, 
    getWinner, 
    loadCandidates, 
    mapVotingState, 
    startVoting, 
    voteForCandidate, 
    waitForTransactionConfirmation, 
    walletListener
} from './utilities/ContractInteractions';

const Voting = () => {
    const [walletAddress, setWalletAddress] = useState('');
    const [status, setStatus] = useState('Unable to connect to the blockchain');
    const [votingState, setVotingState] = useState('NotStarted');
    const [candidates, setCandidates] = useState([]);
    const [hasVoted, setHasVoted] = useState(false);
    const [winner, setWinner] = useState('');

    useEffect(() => {
        const initialize = async () => {
            try {
                const { address, status } = await getCurrentWalletConnected();
                setWalletAddress(address);
                setStatus(status);

                const state = await getVotingState();
                setVotingState(mapVotingState(state));

                const candidates = await loadCandidates();
                setCandidates(candidates);

                const currentWinner = await getWinner();
                setWinner(currentWinner);

                if (address) {
                    const voted = await checkIfVoted(address);
                    setHasVoted(voted);
                }

                walletListener(setWalletAddress, checkIfVoted, setHasVoted, setStatus);
                eventListeners(setStatus, setVotingState, setWinner);
            } catch (err) {
                setStatus('Error loading contract data: ' + err.message);
            }
        };

        initialize();
    }, []);

    const handleConnectWallet = async () => {
        const walletResponse = await connectWallet();
        setWalletAddress(walletResponse.address);
        setStatus(walletResponse.status);
    }

    const handleStartVoting = async () => {
        const response = await startVoting(walletAddress);
        setStatus(response.status);
    }

    const handleVoteForCandidate = async (candidateName) => {
        const voteResponse = await voteForCandidate(walletAddress, candidateName);
        setStatus (voteResponse.status);

        if (voteResponse.txHash) {
            const updateCandidates = await waitForTransactionConfirmation(voteResponse.txHash, setHasVoted, loadCandidates);
            setCandidates(updateCandidates);
        }
    }

    return (
        <div className='box'>
            <div className='header'>
                {!walletAddress && (
                    <button 
                        className='walletButton'
                        onClick={handleConnectWallet}
                    >
                            Connect wallet
                    </button>
                )}

                {walletAddress && walletAddress.length > 0 && (
                    <p className='walletAddress'>
                        Connected: {`${walletAddress.substring(0, 6)}...${walletAddress.substring(walletAddress.length - 4)}`}
                    </p>
                )}
            </div>

            {votingState === 'NotStarted' && walletAddress && (
                <button 
                    className='startVotingButton'
                    onClick={handleStartVoting}
                >
                    Start voting
                </button>
            )}

            <h3>
                {votingState === 'NotStarted' ? 'Voting has not yet started.' : votingState === 'Finished' ? 'Voting has ended.' : ''}
            </h3>

            {votingState === 'Ongoing' && (
                <>
                    <h3>
                        Vote for candidate:
                    </h3>
                    <div className='candidateRow'>
                        {candidates.map((candidate, index) => (
                            <div 
                                key={index}
                                className='candidateBox'
                            >
                                <button
                                    className='voteButton'
                                    onClick={() => handleVoteForCandidate(candidate.name)}
                                    disabled={!walletAddress || hasVoted}
                                >
                                    {candidate.name}
                                </button>
                                <p className='voteCount'>
                                    {candidate.voteCount === '1' ? `${candidate.voteCount} vote` : `${candidate.voteCount} votes`}
                                </p>
                            </div>
                        ))}
                    </div>

                    {hasVoted && (
                        <p className='alreadyVotedMessage'>
                            You have already voted!
                        </p>
                    )}
                </>
            )}

            {votingState === 'Finished' && (
                <h3 className='winner'>
                    Winner: {winner}
                </h3>
            )}

            <p className='status'>
                {status}
            </p>
        </div>
    )
};

export default Voting;