[![Build Status](https://travis-ci.com/rbrtjhs/process.svg?token=haX3CqTq2yjp6nAkGokp&branch=main)](https://travis-ci.com/rbrtjhs/process)
[![Coverage Status](https://coveralls.io/repos/github/rbrtjhs/process/badge.svg?branch=main)](https://coveralls.io/github/rbrtjhs/process?branch=main)

# PROCESS
This project is used machines machines and how they produce products.
The product is known as an item.
Each item is built with specific steps and collection of the specific steps is called process.
The purpose of this project is to manage items through specific process(es) specified by steps.

Process and step are ownable where process should belong to the user and step should belong to the step maker.

## USAGE 
The user will create process. User will create steps and reassign each specific step to the machine. User will create an item.
The user will add steps to the specific process. The user has to add item to the process. After creation of the process user will mark the process as created by calling finishCreation(). 

Ice cream example:
User will create process called CHOCO ICE CREAM PROCESS which will be in status MODIFIABLE.
User will create 5 steps with names in brackets:
- Chocolate mass creation (CHOCOLATE MASS)
- Stick creation (STICK)
- Pouring chocolate mass over stick (POURING)
- Freezing (FREEZING)
- Packing (PACKING)

For each step user will assign to the specific machine which will do it's task.
User will add each step.
User will create item named CHOCO ICE CREAM.
User will finish creation. In this moment process will be in status IN_PROGRESS.

The process can start. Each step will add a detail by creating new contract instance (e.g. String detail) and adding specific details. Once it is finished will call nextStep().
With this approach each step will be responsible for itself and all data will be saved.

Once finished process will be in status FINISHED.

## INSTALL

You can download it via npm:

```
npm i @rbrtjhs/process
```