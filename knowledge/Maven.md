# Maven

## Scope

1. compile

	This is maven default scope. Dependencies with compile scope are needed to build, test, and run the project.

2. provided

	Maven dependency scope provided is used during build and test the project. They are also required to run, but should not exported, because the dependency will be provided by the runtime, for instance, by servlet container or application server.

3. runtime

	Dependencies with maven dependency scope runtime are not needed to build, but are part of the classpath to test and run the project.

4. test

	Dependencies with maven dependency scope test are not needed to build and run the project. They are needed to compile and run the unit tests.

5. system

	Dependencies with system are similar to ones with scope provided. The only difference is system dependencies are not retrieved from remote repository. They are present under project’s subdirectory and are referred from there. See external dependency for more detail.

6. import

	import scope is only supported on a dependency of type pom in the dependencyManagement section. It indicates the dependency to be replaced with the effective list of dependencies in the specified POM’s dependencyManagement section.
	
## Transitivity

| Dependency | compile | provided | runtime | test |
| --- | --- | --- | --- | --- |
| compile | compile | - | runtime | - |
| provided | provided | - | provided | - |
| runtime | runtime | - | runtime | - |
| test | test | - | test | - |



