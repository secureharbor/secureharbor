# Secureharbor

Secureharbor enables to use LLMs in onprem infrastructure, detect and anonimize/denonimize PII in Insurance claims and doing instant claim settlement via blockchain (via Optimism which is an Ethereum L2 Chain). 

## Installation
1. Install kubernetes cluster in in GCP using IaC terraform:
```
cd /Users/sakom/github/lpm/platgpt.io/devops/infrastructure/terraform/environments/production/gcp/accounts/gcp_prod01/regions/us-central1
terraform init
terraform plan
terraform apply
```
2. Deploy LLAMA LLM with Chat-UI in cluster:
```
kubectl create ns llama
kubectl apply -k ./apps/llm-k8s -n llama
```
3. Deploy Presidio in cluster:
```
cd ./apps/presidio
helm install presidio .
kubectl  port-forward svc/presidio-presidio-analyzer 3001:80 &
kubectl port-forward svc/presidio-presidio-anonymizer 3002:80 &
kubectl port-forward svc/presidio-presidio-image-redactor &
```
Link: https://microsoft.github.io/presidio/samples/deployments/k8s

4. Deploy the Blockchain:
```
cd ./apps/secureharbor
npm i
npx hardhat compile
npx hardhat run scripts/Insurance.deploy.js --network optimism
```

5. Make sure all apps are up and running:
```
kubectl get pods -n llama
NAME                                                READY   STATUS    RESTARTS   AGE
llama-gpt-api-78c8f4b9df-zqgws                      1/1     Running   0          3h14m
llama-gpt-ui-8448485c94-xqk6g                       1/1     Running   0          3h25m
presidio-presidio-analyzer-6894fb577f-xh7xx         1/1     Running   0          126m
presidio-presidio-anonymizer-7569b6cf45-vhx5x       1/1     Running   0          131m
presidio-presidio-image-redactor-7648d64cf5-zhp4l   1/1     Running   0          131m
```

6. Use DeepEval to evaluate:
https://github.com/confident-ai/deepeval

## Use case

1. Analyze, anonimize and denonimize PII in Insurance Claims using Presidio running in our k8s cluster:
```
cd ./apps/sample-data

curl -d '{"text":"John Smith drivers license is AC432223", "language":"en", "ssn":"453454354543534534"}' -H "Content-Type: application/json" -X POST http://localhost:3001/analyze 


curl -d '{
"text": "hello world, my name is Jane Doe. My number is: 034453334",
"anonymizers": {
    "PHONE_NUMBER": {
        "type": "mask",
        "masking_char": "*",
        "chars_to_mask": 4,
        "from_end": true
    }
},
"analyzer_results": [
    {
        "start": 24,
        "end": 32,
        "score": 0.8,
        "entity_type": "NAME"
    },
    {
        "start": 24,
        "end": 28,
        "score": 0.8,
        "entity_type": "FIRST_NAME"
    },
    {
        "start": 29,
        "end": 32,
        "score": 0.6,
        "entity_type": "LAST_NAME"
    },
    {
        "start": 48,
        "end": 57,
        "score": 0.95,
        "entity_type": "PHONE_NUMBER"
    }
]}' -XPOST http://localhost:3002/anonymize -H "Content-Type: application/json"
```
2. Upload anonimized data to privateGPT via privateGPT UI:

3. Request customer claim processing

4. Send payout to customer after AI processes claim:
Sample request:
```
https://secureharbor.onrender.com/process-inputs?amount=150&companyWalletAddress=6hjiu3kjhf9783&userWalletAddress=098rwefskjdf13
```
Sample Response:

```
{"status":"success","message":"Claim received and processed successfully for the amount: 150. Smart contracts compiled and deployment script executed.","data":{"companyWalletAddress":"6hjiu3kjhf9783","userWalletAddress":"098rwefskjdf13","amount":"150","compileOutput":"Downloading compiler 0.8.20\nCompiled 1 Solidity file successfully (evm target: paris).\n","deploymentOutput":"Deploying contracts with the account: 0x51A86AD7B88Ec736dC25BB9723bD1601B3B15582\nAccount balance: 493325561331579903\nInsuranceSettlement deployed to: 0xFDaAcC96EdD30a82963a93EEB1ddf92EF1f21Bf3\nTransferring 0.001 ETH to the contract for funding...\nFunding complete.\nSettling claim: sending 0.001 ETH to 0xEd602BAe30F65CbFC6C50598f130c4D18C4362DA\nClaim settled. Transaction hash: 0x5443b76eac5a6bfddc2039d7d4b2f3a8dccbf89717defdbe234ef66c846a48f7\n"}}
```


