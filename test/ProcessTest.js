const Process = artifacts.require('Process');

contract("Process", function(accounts) {
    const PROCESS_NAME = "Process 1";

    it("Should create Process contract with status 0 (MODIFIABLE) and stepIndex = 0", async () => {
        let processContractInstance = await Process.new(PROCESS_NAME);
        assert.ok(await processContractInstance.status(), 0);
        assert.ok(await processContractInstance.stepIndex(),0);
    });
});