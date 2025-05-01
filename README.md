# 🔥 K6 Test Kit

A reusable, configurable stress testing framework built on [k6](https://k6.io/) — perfect for step-by-step performance testing of multiple APIs with HTML and TSV reporting.

---

### 📁 Project Structure

```
k6-stress-test/
├── apis/                # One JS file per API
├── config/
│   └── config.json      # Global config for testing: VU steps, duration, APIs
├── data/                # Test data for api script usage
├── reports/             # All generated reports
├── template/            # Template scripts that reusable
└── utils/               # Utilitie codes
└── k6-run.sh            # Main runner script
└── stress-test.js       # Main index k6
```

---

### ⚙️ Setup
1. Install [k6](https://grafana.com/docs/k6/latest/set-up/install-k6/).

    For MacOS
    ```
    brew install k6
    ```

2. Clone this repo:
   ```bash
   git clone https://github.com/walalaph/k6-stress-test.git
   cd k6-stress-test
   ```

---

### 📦 Configuration

Edit `config/config.json` to control how the stress test behaves:

```json
{
  "VUS": [1, 3, 5],
  "DURATION": "300s",
  "WAIT_BETWEEN_STEPS_SEC": "100s",
  "HTML_REPORT": true,
  "APIS": ["GET-home", "POST-login"]
}

```
#### Config Fields Explained
| Field                   | Description |
|------------------------|-------------|
| `VUS`                  | Array of Virtual Users (VUs) to test in step load. Each value is run one after the other. |
| `DURATION`             | Duration of testing for each VU step (e.g., `"300s"` = 5 minutes per step). |
| `WAIT_BETWEEN_STEPS_SEC` | Pause time between each step, used to let the system stabilize. Must include time unit (e.g., `"100s"`). |
| `HTML_REPORT`          | If `true`, generates a full HTML summary report per run step. |
| `APIS`                 | List of API script filenames (without extension) located in `/apis/` folder. These will be run in sequence. |

---

### 🚀 Run Tests

In your terminal.

Run all APIs defind in `config/config.json`

```bash
sh k6-run.sh
```

Run a specific API:

```bash
API=GET-home sh k6-run.sh
```

---

### 📊 Outputs

- 📄 HTML reports per step in `reports/<api>_<timestamp>/`
- 📑 Summary `.tsv` file per API
- 📈 Live stdout feedback

#### Example Outputs - Summary `.tsv` File
```
API       VU  Iterations  Requests  Error%  Avg(ms)  P90(ms)  Max(ms)  DataSent  DataRecv
GET-home  1   10          10        0%      105.62   110.93   111.17   1140      2300
```

---

### 🧩 Adding a New API

1. Create a new file in the `apis/` directory, e.g., `apis/my-api.js`:
    ```javascript
    import http from 'k6/http';
    import { check } from 'k6';

    export default function () {
        const res = http.get('http://localhost:8080/my-endpoint');
        check(res, { 'status is 200': (r) => r.status === 200 });
    }
    ```

2. Add the new API to the `APIS` array in `config/config.json`:
    ```json
    {
      "APIS": ["GET-home", "POST-login", "my-api"]
    }
    ```
