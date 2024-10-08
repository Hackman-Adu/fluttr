# Introduction

fluttr is a Dart CLI tool simplifies the setup of new Flutter projects by automatically generating a well-structured folder and file layout. Currently, this is designed for personal use, this tool helps eliminate repetitive tasks, streamlining project initialization and boosting productivity. Created this CLI to enhance my workflow efficiency, and it can benefit others who find the generated project structure practical, effective & useful

I am committed to continuously improving this tool, and I welcome suggestions for enhancements to make it more valuable for a broader audience.

Install the CLI using the command below:
`dart pub global activate fluttr`

## Installing

```shell
# Install the fluttr CLI from pub.dev
dart pub global activate fluttr
```

## New Project

Use the `fluttr create <project_name> --org <project_package_name>` command to create a new Flutter Project.

```shell
# Create new Flutter Project called "super"
fluttr create super --org com.organization
```

You can also include other options: Run `fluttr create --help` to see more

## Create Model

Use the `fluttr make:model` command to create a new model.

```shell
# Create a new model called "user"
fluttr make:model user

# Create mutiple models
fluttr make:model auth,user,post
```

## Create Service

Use the `fluttr make:service` command to create a new service.

```shell
# Create new service called "auth"
fluttr make:service auth

# Create multiple services
fluttr make:service auth,post
```

## Create View Model

Use the `fluttr make:view_model` command to create a new view_model.

```shell
# Create a new view model called "auth"
fluttr make:view_model auth

# Create multiple view models
fluttr make:view_model auth,user
```

## Update

Update the CLI using the `fluttr upgrade` command
