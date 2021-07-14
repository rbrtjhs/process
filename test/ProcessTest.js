const Process = artifacts.require('Process');

contract("Process", function(accounts) {
    const PROCESS_NAME = "Process 1";
    const STEP_ADDRESS_1 = accounts[2];
    const STEP_ADDRESS_2 = accounts[3];

    it("Should create Process contract with status 0 (MODIFIABLE) and stepIndex = 0", async () => {
        let processContractInstance = await Process.new(PROCESS_NAME);
        assert.equal(await processContractInstance.status(), 0);
        assert.equal(await processContractInstance.stepIndex(), 0);
    });

    it("Add 2 steps.", async () => {
        let processContractInstance = await Process.new(PROCESS_NAME);
        
        await processContractInstance.addStep(STEP_ADDRESS_1);
        await processContractInstance.addStep(STEP_ADDRESS_2);
        
        assert.equal(await processContractInstance.steps(0), STEP_ADDRESS_1);
        assert.equal(await processContractInstance.steps(1), STEP_ADDRESS_2);
        await processContractInstance.steps(2).catch(x => {
            assert.ok(x.hijackedStack.includes("revert"));
        });
    });

    it("Prevent adding steps if not in MODIFIABLE status.", async () => {
        let processContractInstance = await Process.new(PROCESS_NAME);
        
        await processContractInstance.addStep(STEP_ADDRESS_1);
        await processContractInstance.finishCreation();

        await processContractInstance.addStep(STEP_ADDRESS_2).catch(x => {
            assert.ok(x.hijackedStack.includes("revert"));
        });
    });

    it("Can't finish the process creation which is already in status IN PROGRESS.", async () => {
        let processContractInstance = await Process.new(PROCESS_NAME);
        
        await processContractInstance.addStep(STEP_ADDRESS_1);
        await processContractInstance.finishCreation();
        await processContractInstance.finishCreation().catch(x => {
            assert.ok(x.hijackedStack.includes("revert"));
        });
    });

    it("Finish the process.", async () => {
        let processContractInstance = await Process.new(PROCESS_NAME);
        
        await processContractInstance.addStep(STEP_ADDRESS_1);
        await processContractInstance.finishCreation();

        assert.equal(await processContractInstance.status(), 1);
    });

    it("Prevent creation finishing without steps.", async () => {
        let processContractInstance = await Process.new(PROCESS_NAME);
        
        await processContractInstance.finishCreation().catch(x => {
            assert.ok(x.hijackedStack.includes("revert"));
        });
    });

    it("Remove step.", async () => {
        let processContractInstance = await Process.new(PROCESS_NAME);

        await processContractInstance.addStep(STEP_ADDRESS_1);
        assert.equal(await processContractInstance.steps(0), STEP_ADDRESS_1);
        await processContractInstance.removeStep(0);

        await processContractInstance.stepIndex().catch(x => {
            assert.ok(x.hijackedStack.includes("revert"));
        });
    });

    it("Remove steps.", async () => {
        let processContractInstance = await Process.new(PROCESS_NAME);

        await processContractInstance.addStep(STEP_ADDRESS_1);
        await processContractInstance.addStep(STEP_ADDRESS_2);
        await processContractInstance.addStep(accounts[4]);

        let array = [0,2];
        await processContractInstance.removeSteps(array);

        assert.equal(await processContractInstance.steps(0), STEP_ADDRESS_2);
    });

    it("Try to execute nextStep() function of not Step contract.", async () => {
        let processContractInstance = await Process.new(PROCESS_NAME);

        await processContractInstance.addStep(STEP_ADDRESS_1);
        await processContractInstance.addStep(STEP_ADDRESS_2);
        await processContractInstance.finishCreation();

        await processContractInstance.nextStep().catch(x => {
            assert.ok(x.hijackedStack.includes("revert"));
        });
    });
});