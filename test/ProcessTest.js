const Process = artifacts.require('Process');
const Step = artifacts.require('Step');
const Item = artifacts.require('Item');

contract("Process", function(accounts) {
    let processContractInstance;
    let stepContractInstances;
    let itemContractInstance;

    beforeEach(async () => {
        const PROCESS_NAME = "Process 1";
        const STEP_NAME = "Step ";
        const ITEM_NAME = "Item 1";

        processContractInstance = await Process.new(PROCESS_NAME);
        stepContractInstances = [];
        for (let i = 0; i < 3; i++) {
            let step = await Step.new(STEP_NAME + i, processContractInstance.address);
            stepContractInstances.push(step);
        }
        itemContractInstance = await Item.new(ITEM_NAME, stepContractInstances[0].address); 
    });

    it("Should create Process contract with status 0 (MODIFIABLE) and stepIndex = 0", async () => {
        assert.equal(await processContractInstance.status(), 0);
        assert.equal(await processContractInstance.stepIndex(), 0);
    });

    it("Set item.", async() => {
        await processContractInstance.addStep(stepContractInstances[0].address);
        await processContractInstance.setItem(itemContractInstance.address);
        assert.equal(await processContractInstance.item(), itemContractInstance.address);
    });

    it("Prevent adding steps if not in MODIFIABLE status.", async () => {        
        await processContractInstance.addStep(stepContractInstances[0].address);
        await processContractInstance.setItem(itemContractInstance.address);
        await processContractInstance.finishCreation();

        await processContractInstance.addStep(stepContractInstances[1].address).catch(x => {
            assert.ok(x.hijackedStack.includes("revert"));
        });
    });


    it("Add 2 steps.", async () => {
        await processContractInstance.addStep(stepContractInstances[0].address);
        await processContractInstance.addStep(stepContractInstances[1].address);
        
        assert.equal(await processContractInstance.steps(0), stepContractInstances[0].address);
        assert.equal(await processContractInstance.steps(1), stepContractInstances[1].address);
        await processContractInstance.steps(2).catch(x => {
            assert.ok(x.hijackedStack.includes("revert"));
        });
    });

    it("Can't finish the process creation which is already in status IN PROGRESS.", async () => {
        await processContractInstance.addStep(stepContractInstances[0].address);
        await processContractInstance.setItem(itemContractInstance.address);
        await processContractInstance.finishCreation();
        await processContractInstance.finishCreation().catch(x => {
            assert.ok(x.hijackedStack.includes("revert"));
        });
    });

    it("Finish the process.", async () => {
        await processContractInstance.addStep(stepContractInstances[0].address);
        await processContractInstance.setItem(itemContractInstance.address);
        await processContractInstance.finishCreation();

        assert.equal(await processContractInstance.status(), 1);
    });

    it("Prevent creation finishing without steps.", async () => {
        await processContractInstance.finishCreation().catch(x => {
            assert.ok(x.hijackedStack.includes("revert"));
        });
    });

    it("Remove step.", async () => {
        await processContractInstance.addStep(stepContractInstances[0].address);
        assert.equal(await processContractInstance.steps(0), stepContractInstances[0].address);
        await processContractInstance.removeStep(0);

        await processContractInstance.stepIndex().catch(x => {
            assert.ok(x.hijackedStack.includes("revert"));
        });
    });

    it("Remove steps.", async () => {
        await processContractInstance.addStep(stepContractInstances[0].address);
        await processContractInstance.addStep(stepContractInstances[1].address);
        await processContractInstance.addStep(stepContractInstances[2].address);

        let array = [0,2];
        await processContractInstance.removeSteps(array);

        assert.equal(await processContractInstance.steps(0), stepContractInstances[1].address);
    });

    it("Try to execute nextStep() function of not Step contract.", async () => {
        await processContractInstance.addStep(stepContractInstances[0].address);
        await processContractInstance.addStep(stepContractInstances[1].address);
        await processContractInstance.setItem(itemContractInstance.address);
        await processContractInstance.finishCreation();
        await processContractInstance.nextStep().catch(x => {
            assert.ok(x.hijackedStack.includes("revert"));
        });
    });
});