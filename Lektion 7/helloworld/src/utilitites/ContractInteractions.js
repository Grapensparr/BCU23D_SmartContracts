const alchemyKey = process.env.REACT_APP_ALCHEMY_KEY;
const { createAlchemyWeb3 } = require('@alch/alchemy-web3');
const web3 = createAlchemyWeb3(alchemyKey);

const contractABI = require('../contract-abi.json');
const contractAddress = process.env.REACT_APP_CONTRACT

export const helloWorldContract = new web3.eth.Contract(
    contractABI,
    contractAddress
);

// Ansluta användarens plånbok till applikationen
export const connectWallet = async () => {
    // Kontrollera om användaren har installerat Ethereum programvara i sin webbläsare
    if (window.ethereum) {
        try {
            // Försök till att begära plånboksadresser från Metamask
            const addressArray = await window.ethereum.request({
                // Detta öppnar MeatMask och låter användaren välja en plånbok som den vill ansluta till vår applikation
                method: 'eth_requestAccounts'
            });

            // Om det lyckas vill vi returnera adressen och ett statusmeddelande
            return {
                status: 'Write a new message and send it to the blockchain.',
                address: addressArray[0]
            }
        } catch (err) {
            return {
                status: err.message,
                address: ''
            }
        }
    } else {
        // Om det inte finns någon Ethereum programvara installerad vill vi tipsa användaren om MetaMask
        return {
            status: (
                <span>
                    Want to use this application?<br/>
                    <a target='blank' href='https://metamask.io/download.html'>
                        Install MetaMask for your browser!
                    </a>
                </span>
            ),
            address: ''
        };
    }
};

// Kontrollera om plånboken redan är ansluten
export const getCurrentWalletConnected = async () => {
    if (window.ethereum) {
        try {
            // Begär ut en lista över anslutna konton
            const accounts = await window.ethereum.request({
                method: 'eth_accounts'
            });

            // Om det finns konton anslutna, returnera det första kontot och ett statusmeddelande
            if (accounts.length > 0) {
                return {
                    status: 'Write a new message and send it to the blockchain.',
                    address: accounts[0]
                }
            } else {
                // Om inga konton är anslutna vill vi be användaren att ansluta sitt konto
                return {
                    status: 'Connect your wallet using the top right button.',
                    address: ''
                };
            }
        } catch (err) {
            return {
                status: err.message,
                address: ''
            };
        }
    } else {
        // Om det inte finns någon Ethereum programvara installerad vill vi tipsa användaren om MetaMask
        return {
            status: (
                <span>
                    Want to use this application?<br/>
                    <a target='blank' href='https://metamask.io/download.html'>
                        Install MetaMask for your browser!
                    </a>
                </span>
            ),
            address: ''
        };
    }
};

// Lyssna efter förändringar i plånboksadressen
export const walletListener = (setWalletAddress, setStatus) => {
    if (window.ethereum) {
        window.ethereum.on('accountsChanged', (accounts) => {
            if (accounts.length > 0) {
                setWalletAddress(accounts[0]);
                setStatus('Write a new message and send it to the blockchain.')
            } else {
                // Om inga konton längre är anslutna, rensa adressen och uppmana användaren att ansluta sin plånbok
                setWalletAddress('');
                setStatus('Connect your wallet using the top right button.')
            }
        });
    }
};

export const loadCurrentMessage = async () => {
    const message = await helloWorldContract.methods.message().call();
    return message;
};

export const updateMessage = async (address, message) => {
    // Kontrollerar om Ethereum programvara finns i webbläsaren och om en användare har anslutit
    if (!window.ethereum || !address) {
        return {
            status: 'You must connect your wallet in order to update the message on the blockchain.'
        };
    }

    // Kontrollera om meddelandet är tomt. Trim är ett sätt för att ta bort extra mellanslag.
    if (message.trim() === '') {
        return {
            status: 'Your message cannot be an empty string. Please try again!'
        }
    }

    // Bygger upp transaktionsparametrarna för att kunna interagera med kontraktet
    const transactionParameters = {
        // Mottagaren är kontraktets adress
        to: contractAddress,
        // Avsändarens adress
        from: address,
        // Anrop av setMessage funktionen i kontraktet, där vi skickar in det nya meddelandet
        data: helloWorldContract.methods.setMessage(message).encodeABI()
    }

    try {
        // Skicka en begäran om transaktion
        const txHash = await window.ethereum.request({
            method: 'eth_sendTransaction',
            params: [transactionParameters]
        });

        // Returnera en länk till Etherscan där användaren kan följa sin transaktion
        return {
            status: (
                <span>
                    <a target='blank' href={`https://sepolia.etherscan.io/tx/${txHash}`}>
                        View the status of your transaction on Etherscan.
                    </a><br/>
                    Once the transaction is verified by the network, the message will be updated automatically.
                </span>
            ),
        };
    } catch (err) {
        return {
            status: err.message
        };
    }
};

export const eventListener = (setCurrentMessage, setNewMessage, setStatus) => {
    // Lyssna på MessageUpdate-händelser
    helloWorldContract.events.MessageUpdate({}, (err, data) => {
        if (err) {
            setStatus(err.message);
        } else {
            setCurrentMessage(data.returnValues[1]);
            setNewMessage('');
            setStatus('The message has been updated!');
        }
    });
};