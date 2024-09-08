import { useEffect, useState } from 'react';
import './App.css';
import {
    connectWallet,
    getCurrentWalletConnected,
    walletListener,
    loadCurrentMessage,
    updateMessage,
    eventListener
} from './utilitites/ContractInteractions';

const HelloWorld = () => {
    const [walletAddress, setWalletAddress] = useState('');
    const [status, setStatus] = useState('');
    const [currentMessage, setCurrentMessage] = useState('Unable to connect to the blockchain');
    const [newMessage, setNewMessage] = useState('');

    useEffect(() => {
        const initialize = async () => {
            try {
                const message = await loadCurrentMessage();
                setCurrentMessage(message);

                const { address, status } = await getCurrentWalletConnected();
                setWalletAddress(address);
                setStatus(status);

                if (address) {
                    walletListener(setWalletAddress, setStatus);
                    eventListener(setCurrentMessage, setNewMessage, setStatus);
                }
            } catch (err) {
                setStatus('Error loading data: ' + err.message);
            }
        };

        initialize();
    }, []);

    const handleConnectWallet = async () => {
        const walletResponse = await connectWallet();
        setStatus(walletResponse.status);
        setWalletAddress(walletResponse.address);
    }

    const handleUpdateMessage = async () => {
        const { status } = await updateMessage(walletAddress, newMessage);
        setStatus(status);
    }

    return (
        <div className='container'>
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
            <div className='box'>
                <h3>
                    Current message:
                </h3>
                <p>
                    {currentMessage}
                </p>

                <h3>
                   Send a new message 
                </h3>
                <div className='inputGroup'>
                    <input
                        type='text'
                        placeholder='Enter message'
                        onChange={(e) => setNewMessage(e.target.value)}
                        value={newMessage}
                    />

                    <p className='status'>
                        {status}
                    </p>

                    <button 
                        className='sendMessage'
                        onClick={handleUpdateMessage}
                    >
                        Send message
                    </button>
                </div>
            </div>
        </div>
    );
};

export default HelloWorld;