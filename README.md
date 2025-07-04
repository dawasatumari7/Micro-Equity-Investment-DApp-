# 🚀 Micro-Equity Investment DApp

A decentralized platform for micro-equity investments in early-stage projects using Clarity smart contracts.

## 🎯 Features

- Create investment projects with customizable shares and pricing
- Purchase equity tokens representing ownership
- Distribute profits to token holders
- Transfer shares between investors
- Track investment holdings and returns

## 🔧 Smart Contract Functions

### For Project Owners

- `create-project`: Launch a new investment opportunity
- `distribute-profits`: Share profits with token holders

### For Investors

- `invest`: Purchase shares in a project
- `transfer-shares`: Trade shares with other investors
- `get-project`: View project details
- `get-investor-shares`: Check investment holdings

## 📝 Usage Example

1. Project owner creates an investment opportunity:
```clarity
(contract-call? .micro-equity-investment create-project "Tech Startup A" u1000 u100)
```

2. Investor purchases shares:
```clarity
(contract-call? .micro-equity-investment invest u0 u10)
```

3. Transfer shares to another investor:
```clarity
(contract-call? .micro-equity-investment transfer-shares u0 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM u5)
```

## 🔒 Security

- Owner-only profit distribution
- Safe share transfer mechanisms
- Built-in balance checks
```

