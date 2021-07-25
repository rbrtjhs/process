const Process = artifacts.require('Process');
const Step = artifacts.require('Step');
const Item = artifacts.require('Item');
const StringDetail = artifacts.require('StringDetail');
const expectRevert = require("@openzeppelin/test-helpers/src/expectRevert");

contract("Item", function(accounts) {
    const PROCESS_NAME = "Process 1";
    const STEP_NAME = "Step 1";
    const ITEM_NAME = "Item 1";
    const STRING_DETAIL = "String Detail 1";

    it("Should create process, step and item and link them", async () => {
        let processContractInstance = await Process.new(PROCESS_NAME);
        let stepContractInstance = await Step.new(STEP_NAME, processContractInstance.address);
        await processContractInstance.addStep(stepContractInstance.address);
        let itemContractInstance = await Item.new(ITEM_NAME, processContractInstance.address);
        assert.equal(await processContractInstance.name(), PROCESS_NAME);
        assert.equal(await stepContractInstance.name(), STEP_NAME);
        assert.equal(await itemContractInstance.name(), ITEM_NAME);
        assert.equal(await itemContractInstance.process(), processContractInstance.address);
    });

    it("Add detail", async () => {
        let processContractInstance = await Process.new(PROCESS_NAME);
        let stepContractInstance = await Step.new(STEP_NAME, processContractInstance.address);
        await processContractInstance.addStep(stepContractInstance.address);
        let itemContractInstance = await Item.new(ITEM_NAME, processContractInstance.address);
        await processContractInstance.setItem(itemContractInstance.address);
        await processContractInstance.finishCreation();
        let detail = await StringDetail.new(STRING_DETAIL);
        await stepContractInstance.addDetail(detail.address);
        assert.equal(await itemContractInstance.details(stepContractInstance.address, 0), detail.address);
    });

    it("Set initial step", async () => {
        let process = accounts[1];
        let initialStep = accounts[2];
        let item = await Item.new(ITEM_NAME, process);
        await item.setInitialStep(initialStep, {from: process});
        assert.equal(await item.initialStep(), initialStep);
        assert.equal(await item.currentStep(), initialStep);
    });

    it("Prevent adding detail if not called from current step.", async () => {
        let process = await Process.new(PROCESS_NAME);
        let item = await Item.new(ITEM_NAME, process.address);
        await expectRevert(item.addDetail(accounts[5]), "Only current step can change");
    });
});