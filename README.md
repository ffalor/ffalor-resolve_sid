# resolve_sid

## Table of Contents

1.  [Description](#description)
2.  [Requirements](#Requirements)
3.  [Usage - Configuration options and additional functionality](#usage)
    -   [Puppet Tasks and Bolt](#Puppet-Task-and-Bolt)
    -   [Puppet Task API](#Puppet-Task-Api)
4.  [Development - Guide for contributing to the module](#development)

## Description

This module includes a puppet task to remove unresolvable SIDs from window local groups.

This task can be exposed as a service via the puppet task endpoint to allow remote execution.

## Requirements

This module is compatible with Puppet Enterprise and Puppet Bolt.

-   To run tasks with Puppet Enterprise, PE 2018.1 or later must be installed on the machine from which you are running task commands. Machines receiving task requests must be Puppet agents.
-   To run tasks with Puppet Bolt, Bolt 1.0 or later must be installed on the machine from which you are running task commands. Machines receiving task requests must have SSH or WinRM services enabled.

## Usage

### Puppet Task and Bolt

To run a resolve_sid task, use the task command, specifying the command to be executed.

-   With PE on the command line, run `puppet task run resolve_sid group=administrators`.
-   With Bolt on the command line, run `bolt task run resolve_sid group=administrators`.

### Puppet Task API

endpoint: `https://<puppet>:8143/orchestrator/v1/command/task`

method: `post`

body:

```json
{
  "environment": "production",
  "task": "resolve_sid",
  "params": {
    "group": "Administrators",
  },
  "description": "Description for task",
  "scope": {
    "nodes": ["saturn.example.com"]
  }
}
```

You can also run tasks in the PE console. See PE task documentation for complete information.