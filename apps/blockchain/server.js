const { exec } = require('child_process');
const express = require('express');
const app = express();

// Define the port we will listen on
const PORT = 3000;

// Endpoint that accepts two parameters: `param1` and `param2`
app.get('/process-inputs', (req, res) => {
    // Extract parameters from query string
    const amount = req.query.amount;
    const companyWalletAddress = req.query.companyWalletAddress;
    const userWalletAddress = req.query.userWalletAddress;

    // You can add additional logic here to process the parameters as needed

    // Check if both parameters are provided
    if (amount && companyWalletAddress && userWalletAddress) {
        // Compile the smart contracts with Hardhat
        exec('npx hardhat compile', (compileError, compileStdout, compileStderr) => {
            if (compileError) {
                console.error(`compile error: ${compileError}`);
                return res.status(500).json({
                    status: 'error',
                    message: 'Failed to compile the smart contracts.'
                });
            }

            // Log the compile stdout and stderr
            console.log(`compile stdout: ${compileStdout}`);
            console.error(`compile stderr: ${compileStderr}`);

            // After successful compilation, run the deployment script
            exec('npx hardhat run scripts/Insurance.deploy.js --network optimism', (deployError, deployStdout, deployStderr) => {
                if (deployError) {
                    console.error(`deploy error: ${deployError}`);
                    return res.status(500).json({
                        status: 'error',
                        message: 'Failed to execute the deployment script.'
                    });
                }

                // Log the deploy stdout and stderr
                console.log(`deploy stdout: ${deployStdout}`);
                console.error(`deploy stderr: ${deployStderr}`);

                // Success response
                res.status(200).json({
                    status: 'success',
                    message: `Claim received and processed successfully for the amount: ${amount}. Smart contracts compiled and deployment script executed.`,
                    data: {
                        companyWalletAddress: companyWalletAddress,
                        userWalletAddress: userWalletAddress,
                        amount: amount,
                        compileOutput: compileStdout,
                        deploymentOutput: deployStdout
                    }
                });
            });
        });
    } else {
        // Error response for missing parameters
        res.status(400).json({
            status: 'error',
            message: 'Missing one or more input parameters.'
        });
    }
});

// Start the server
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});