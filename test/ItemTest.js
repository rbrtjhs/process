const Process = artifacts.require('Process');
const Step = artifacts.require('Step');
const Item = artifacts.require('Item');

contract("Item", function(accounts) {
    const PROCESS_NAME = "Process 1";
    const STEP_NAME = "Step 1";
    const ITEM_NAME = "Item 1";

    it("Should create process, step and item and link them", async () => {
        let processContractInstance = await Process.new(PROCESS_NAME);
        //console.log(processContractInstance.address);
        let stepContractInstance = await Step.new(STEP_NAME, processContractInstance.address);
        let itemContractInstance = await Item.new(ITEM_NAME, stepContractInstance.address);
        assert.equal(await processContractInstance.name(), PROCESS_NAME);
        assert.equal(await stepContractInstance.name(), STEP_NAME);
        assert.equal(await itemContractInstance.name(), ITEM_NAME);
    })
});