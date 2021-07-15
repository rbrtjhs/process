const Process = artifacts.require('Process');
const Step = artifacts.require('Step');

contract("Step", function(accounts) {
    const PROCESS_NAME = "Process 1";
    const STEP_NAME = "Step 1";

    it("Should create process and step and link them", async () => {
        let processContractInstance = await Process.new(PROCESS_NAME);
        let stepContractInstance = await Step.new(STEP_NAME, processContractInstance.address);
        assert.equal(await processContractInstance.name(), PROCESS_NAME);
        assert.equal(await stepContractInstance.name(), STEP_NAME);
        assert.equal(await processContractInstance.steps(0), stepContractInstance.address);
    });   
});