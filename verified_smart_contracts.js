/// Script used to download verified smart contracts from EtherScan
/// All files are stored in an excel in EtherScan webpage.
/// An API is avaiable for downloading contracts, but only downloads one per request
/// so, it was needed to make a recursion.

const fs = require("fs");
const csv = require("csvtojson");
const axios = require("axios");

(async () => {
    // Load exported verified contracts address
    let contracts = await csv().fromFile("export-verified-contractaddress-opensource-license.csv");
    let contractsList = Object.values(contracts);
    const PATH = "<YOUR-PATH>\\EtherScan_SmartContracts";
    const key =  "<YOUR-KEY>";
    let etherScanRequest;
    var i = 1;

    for (i; i < contractsList.length; i++) {
        etherScanRequest = `https://api.etherscan.io/api?module=contract&action=getsourcecode&address=${contractsList[i]['field2']}&apikey=${key}`

        await axios
            .get(etherScanRequest)
            .then((response) => {
                let responseList = Object.values(response['data']['result']);
                fs.writeFileSync(`${PATH}\\${contractsList[i]['field3']}.sol`, responseList[0]['SourceCode'], (err) => {
                    if(err)
                    {
                        return console.log("It was not possible to download the file.");
                    }     
                })
            })
    }
})();