const Process = artifacts.require('Process');

contract("Process", function(accounts) {
    it("Should create Process contract with status 0 (MODIFIABLE) and stepIndex = 0", async () => {
        let processContractInstance = await Process.new();
        assert.ok(await processContractInstance.status(), 0);
        assert.ok(await processContractInstance.stepIndex(),0);
    });
});