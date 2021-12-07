const Process = artifacts.require('Process');
const Step = artifacts.require('Step');
const Item = artifacts.require('Item');
const ItemRegistry = artifacts.require('ItemRegistry');

const {
    expectEvent,  // Assertions for emitted events
    expectRevert, // Assertions for transactions that should fail
} = require('@openzeppelin/test-helpers');

contract("Process", function(accounts) {
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
        await processContractInstance.addItem(itemContractInstance.address);
    });

    it("Should create Process contract with status 0 (MODIFIABLE)", async () => {
        assert.equal(await processContractInstance.name(), PROCESS_NAME);
        assert.equal(await processContractInstance.status(), 0);
        assert.equal(await processContractInstance.steps(NUMBER_OF_STEPS), stepContractInstances[NUMBER_OF_STEPS - 1].address);
    });

    it("Add item.", async() => {
        let itemRegistry = await (ItemRegistry.at(await(processContractInstance.itemRegistry())));
        let item = await itemRegistry.items(0);
        assert.equal(item, itemContractInstance.address);
    });

    it("Add steps", async () => {
        for (let i = 0; i < NUMBER_OF_STEPS; i++) {
            assert.equal(await processContractInstance.steps(i + 1), stepContractInstances[i].address);
        }
    });

    it("Finish the process.", async () => {
        await processContractInstance.finishCreation();

        assert.equal(await processContractInstance.status(), 1);
    });

    it("Remove steps.", async () => {
        let array = [1,3];
        await processContractInstance.removeSteps(array);

        assert.equal(await processContractInstance.steps(1), stepContractInstances[1].address);
    });

    it("Remove step.", async () => {
        assert.equal(await processContractInstance.steps(1), stepContractInstances[0].address);
        await processContractInstance.removeStep(1);
        assert.equal(await processContractInstance.steps(1), stepContractInstances[1].address);
    });

    it("Prevent adding steps if not in MODIFIABLE status.", async () => {    
        await processContractInstance.finishCreation();

        await expectRevert(processContractInstance.addStep(stepContractInstances[0].address), "Process is in not in desired status");
    });

    it("Try to finish creation of non Step contract.", async () => {
        let process = await Process.new(PROCESS_NAME);
        await process.addStep(accounts[5]);
        await process.addItem(accounts[6]);
        await expectRevert(process.finishCreation(), "revert");
    });

    it("Try to finish creation of non Item contract." , async () => {
        let process = await Process.new(PROCESS_NAME);
        let step = await Step.new(STEP_NAME, process.address);
        await process.addStep(step.address);
        await process.addItem(accounts[5]);
        await debug(process.finishCreation());
    })

    it("Prevent creation finishing without steps.", async () => {
        let process = await Process.new(PROCESS_NAME);
        await expectRevert(process.finishCreation(), "Process needs at least 1 step");
    });
    
    it("Prevent creation finishing without item.", async () => {
        let process = await Process.new(PROCESS_NAME);
        await process.addStep(accounts[5]);
        await expectRevert(process.finishCreation(), "Process needs at least one item");
    });

    it("Prevent retrieve not-existing step.", async () => {
        assert.equal(await processContractInstance.steps(1), stepContractInstances[0].address);
        assert.equal(await processContractInstance.steps(3), stepContractInstances[2].address);
        await expectRevert(processContractInstance.steps(4), "revert");
    });

    it("Can't finish the process creation which is already in status IN PROGRESS.", async () => {
        await processContractInstance.finishCreation();
        await expectRevert(processContractInstance.finishCreation(), "Process is in not in desired status");
    });
});