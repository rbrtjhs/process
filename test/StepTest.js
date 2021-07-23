const Process = artifacts.require('Process');
const Step = artifacts.require('Step');
const Item = artifacts.require('Item');
const Detail = artifacts.require('Detail');
const StringDetail = artifacts.require('StringDetail');

contract("Step", function(accounts) {
    const PROCESS_NAME = "Process 1";
    const STEP_NAME = "Step ";
    const ITEM_NAME = "Item 1";
    const NUMBER_OF_STEPS = 3;

    let processContractInstance;
    let stepContractInstances;
    let itemContractInstance;

    beforeEach(async () => {

        processContractInstance = await Process.new(PROCESS_NAME);
        stepContractInstances = [];
        for (let i = 0; i < NUMBER_OF_STEPS; i++) {
            let step = await Step.new(STEP_NAME + i, processContractInstance.address);
            await processContractInstance.addStep(step.address);
            stepContractInstances.push(step);
        }
        itemContractInstance = await Item.new(ITEM_NAME, processContractInstance.address);
        await processContractInstance.setItem(itemContractInstance.address); 
        await processContractInstance.finishCreation();
    });

    it("Add detail for each step and finish the process.", async () => {
        for (let i = 0; i < stepContractInstances.length; i++) {
            assert.equal(await itemContractInstance.currentStep(), stepContractInstances[i].address);
            let stringDetail = await StringDetail.new("Test detail " + i);
            await stepContractInstances[i].addDetail(stringDetail.address);
            assert.equal(await itemContractInstance.details(stepContractInstances[i].address, 0), stringDetail.address);
            await processContractInstance.nextStep();
        }
        assert.equal((await processContractInstance.status()).toNumber(), 2);
    });
});