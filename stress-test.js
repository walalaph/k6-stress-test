import { htmlReport } from "https://raw.githubusercontent.com/benc-uk/k6-reporter/main/dist/bundle.js";
import { textSummary } from "https://jslib.k6.io/k6-summary/0.0.1/index.js";

const apiName = __ENV.API_NAME;
if (!apiName) throw new Error("Missing API_NAME");

const apiModule = require(`./api-script/${apiName}.js`);
export default apiModule.default;

const enableReport = (__ENV.HTML_REPORT || "").toLowerCase() === "true";
const path = __ENV.REPORT_PATH || "reports/result.html";

export function handleSummary(data) {
  const result = {
    stdout: textSummary(data, { indent: " ", enableColors: true }),
  };

  if (enableReport) {
    result[path] = htmlReport(data);
  }

  return result;
}
