# Capriccio
![Swift 4.2](https://img.shields.io/badge/Swift-4.2-blue.svg)
[![Build Status](https://app.bitrise.io/app/ac2572c809b906b7/status.svg?token=or92GFZDMVH_iZxnvEHyfw&branch=master)](https://app.bitrise.io/app/ac2572c809b906b7)
[![codecov](https://codecov.io/gh/f-meloni/capriccio/branch/master/graph/badge.svg)](https://codecov.io/gh/f-meloni/capriccio)

Capriccio is a tool to generate UI Tests from gherkins `.feature` files.

Capriccio generates test files using [XCTest-Gherkin](https://github.com/net-a-porter-mobile/XCTest-Gherkin)

# An example of how it works
If you have a feature files like
```
Feature: Feature number one

Scenario: Scenario I want to  test
Given I'm in a situation
When something happens
Then something else happens

Scenario: Other scenario I want to  test
Given I'm in another situation
When something different happens
Then something else happens
```

It generates:

```swift
import XCTest
import XCTest_Gherkin

final class FeatureNumberOne: XCTestCase {
    func testScenarioIWantToTest() {
        Given("I'm in a situation")
        When("Something happens")
        Then("Something else happens")
    }

    func testOtherScenarioIWantToTest() {
        Given("I'm in another situation")
        When("Something different happens")
        Then("Something else happens")
    }
}
```

# What is the benefit of using Capriccio?
Gherkin feature files can be easly shared between different platform.
With Capriccio you to generate executable code from the feature files on a specific folder, all you have to do is run Capriccio as part of your build process (For example in a script phase).

### Runtime vs Compile time
There a lot of different tools that allows to run tests from a feature files, like [Cumberish](https://github.com/Ahmed-Ali/Cucumberish) or [XCTest-Gherkin](https://github.com/net-a-porter-mobile/XCTest-Gherkin).
But they generates the tests at runtime.
By generating the tests at compile time you get some benefits:
- You can use the navigator to see, inspect and re run the tests
- You have a better integration with some CI services
- You can actually see the generated test code

# How to use it

to use it just run:
```bash
capriccio source destination <option>
```
**source**                  The path to the folder that contains the feature files
**destination**             The path to the folder where the swift files will be generated

# Personalise setUp and tearDown
Your UI Tests will probably need to do something that is specific to your code base before and after every test.
In order to allow Capriccio to support all this needs you can use the `-c` or `--class-type` option.
This allows you to create a generic class that you can use as superclass for all the generated classes.

e.g.

```swift
class GherkinTestCase: XCTestCase {
    var mockedServer: MockedServer
    var stepDefinition: StepDefinitions!
    var application: App!

    override func setUp() {
        super.setUp()
        mockedServer = MockedServer()
        mockedServer.start()
        
        stepDefinition = StepDefinitions(testCase: self)

        application = App()
        application.launch()
    }

    override func tearDown() {
        mockedServer.stop()
        application.terminate()
        super.tearDown()
    }
}
```

Then if you run:

```bash
capriccio source destination -c GherkinTestCase
```

All the generated classes will be a subclass of `GherkinTestCase` instead of a subclass of `XCTestCase`

# Scenario outline
Capriccio creates a different test for each example.

e.g.

```
Feature: Feature number one

Scenario Outline: Scenario I want to  test
Given I'm in a situation
When something happens <key1>
Then something else happens <key2>
Examples:
| key1 | key2 |
| value1 | value2 |
| value3 | value4 |
```
Generates:
```swift
import XCTest
import XCTest_Gherkin

final class FeatureNumberOne: XCTestCase {
    func testScenarioIWantToTestWithValue1AndValue2() {
        Given("I'm in a situation")
        When("Something happens value1")
        Then("Something else happens value2")
    }
        
    func testScenarioIWantToTestWithValue3AndValue4() {
        Given("I'm in a situation")
        When("Something happens value3")
        Then("Something else happens value4")
    }
}
```
