---
title: "VPBank Project Case Study & Technical Interview Cheatsheet"
date: 2024-02-15T10:00:00+07:00
draft: false
categories: ["Interview Prep"]
tags: ["Interview", "System Design", "VPBank", "Case Study", "GitOps"]
---

# [Contributed to projects](#contributed)

# [Middle task](#middle)
# [recommend tech](#tech)


# [Event architecture vs microservice](#event-architecture-microservice)
# [Dependency Injection](#DI)

# [Kind of Test](#test)

# [Token](#oauth-2)


# [I18n](#iid)
# [React Hooks](#hooks)
# [Redux](#context-redux)

# [Agile scrum](#agile)
# [System design](#design)

# Contributed
- Help team to design a scalable architecture, choose suitable technique.
- Reviews code to ensure high-quality code .
- Mentored junior developers, helping them improve their skills through code reviews, and knowledge sharing.
- Collaborated with the product owner to prioritize and plan the next sprints, ensuring alignment between development and business requirements.
- working closely with the team to resolve bugs and improve system reliability.

# Event architecture microservice
- Microservices focus on decomposing an application into independently services, 
Each microservice is responsible for a specific business and can be scaled independently. 
Each service can communicate each other over APIs or message queues. 
- Event-Driven Architecture emphasizes the use of events to communicate between different components or services. 
Services publish events to an event bus, and other services react to those events without direct calls.

## Traditional Architecture
This type of architecture relies on direct, often synchronous interactions between services. Here, one service calls another, waits for a response, and moves to the next step. Think of it as a predictable chain where each link depends on the last.

- Pros:

  -  Easier to understand and debug: Because processes follow a clear, linear path.
  - Straightforward error handling: Problems are contained within the calling chain.
  - Predictable performance: Since calls are direct, the flow of operations is more controlled.
- Cons:

  - Not as scalable: Each service waits on the previous, which can create bottlenecks under heavy load.
  - Harder to modify: If one service needs to change, it may affect all others directly connected to it.
  - Single point of failure: If one component goes down, it can disrupt the entire process chain.

## Event-Driven Architecture
In an event-driven setup, components communicate by broadcasting events instead of direct calls. 
Each service can emit or respond to events as they happen, allowing for more independence and flexibility.

Pros:

- Highly scalable: Each service processes events asynchronously, so they don’t have to wait on each other.
- Flexible and modular: Changes in one service don’t directly impact others.
- Resilient: If one component fails, it doesn’t bring down the whole system, as other services can continue processing events.

Cons:

- Complex to design and debug: Since everything isn’t neatly sequential, tracing the flow of events can be tricky.
- Harder to maintain data consistency: Different services work independently, making it harder to synchronize data.
- Infrastructure overhead: Requires event brokers and more resources to handle, store, and manage events reliably.

## Example
- Order Processing and Inventory Check: a customer places an order for multiple items, the system synchronously checks each item’s availability in the inventory.

- Pros:

    - Consistency: Inventory and order states remain in sync, reducing the risk of overselling.
    - Immediate feedback: The customer is quickly informed if any item is unavailable or if payment fails.
- Cons:

    - Scalability limits: Under high order volumes, response times may slow as each process waits on the previous one.
    - Failure points: A failure in inventory or payment systems blocks the entire order process.

- Order is  Placed, publishes an event to an event broker, and then Multiple services like mail serivce, shipping service can consume that message.



# Test
- Data-Driven Testing:
  - Pros:

    - Reusable test scripts for various inputs.
    - Comprehensive input/output coverage.
    - Efficient and easy to maintain with data updates.
  - Cons:

    - Complex setup and external data handling.
    - Harder to debug specific failures.
    - May increase execution time with large data sets.
    - Limited focus on overall behavior.

- Behavior Testing:
Pros:

  - Aligns with business/user expectations.
  - Readable and stakeholder-friendly.
  - Validates user experience, not just functionality.
Cons:

  - Time-consuming to write.
  - Learning curve for new tools (e.g., Ginkgo, Cucumber).
  - Maintenance overhead with frequent updates.
  - Not suitable for low-level code testing.
Summary:

Use Data-Driven for validating code with multiple inputs.
Use Behavior Testing for ensuring the system meets user scenarios and business requirements.
Best results often come from combining both methods.


## unit test =======
- Unit test: Tests individual units or components of code in isolation, typically a single function, method, or class. 
  - testify, sqlmock, httpmock
- Integration Testing:  Tests the interaction between multiple units or modules to ensure they work together as expected. - consideration test
    - react: @testing-library/react @testing-library/jest-dom
    - go: testconainer, httptest
- Functional Testing: Tests specific functions of an application, validating output based on specific inputs.
- End-to-End (E2E) Testing: Simulates real user scenarios to verify that the application works end-to-end.
- Performance Testing: Tests the application’s speed, scalability, and stability under load. Simulates high usage to ensure reliability, identifies performance bottlenecks.
- Load Testing: Tests the application under expected load to ensure performance meets requirements. Detects behavior under normal conditions, helps set baselines.

# Oauth 2
- A refresh token is a credential used to obtain a new access token without requiring the user to reauthenticate.
- Oauth2 flow 
    - User Authorization: The user is directed to an authorization server (like Google, Facebook, etc.) and logs in if necessary.
    - Authorization Code: The authorization server redirects the user back to the application’s server with an authorization code.
    - Token Exchange: The application server exchanges the authorization code for an access token and, optionally, a refresh token.
    - Resource Access: The application can now use the access token to access the user's resources.


# IID
- Internationalization and Localization in Development
-  it provides tools and functions to help you manage translations within your app.
- Selective Translation: The library typically translates only the text that you explicitly mark for translation. This means you need to wrap the text you want to translate in specific components or functions provided by the library. The entire application won't be automatically translated without proper implementation.
- Code Structure: Centralized Translation File (JSON),  Use translation keys instead of hardcoded strings t('greeting.hello')
- Fallback Mechanism: Implement a fallback mechanism for cases where a translation is not available. This could involve defaulting to English or providing a placeholder.
```
// src/i18n.js
import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';

// Translation resources
const resources = {
  en: {
    translation: {
      greeting: "Hello, World!",
      welcome: "Welcome to our application!",
      button: {
        submit: "Submit",
      },
    },
  },
  fr: {
    translation: {
      greeting: "Bonjour, le monde!",
      welcome: "Bienvenue dans notre application!",
      button: {
        submit: "Soumettre",
      },
    },
  },
};

i18n
  .use(initReactI18next) // Passes i18n down to react-i18next
  .init({
    resources,
    lng: "en", // Default language
    fallbackLng: "en", // Fallback language
    interpolation: {
      escapeValue: false, // React already does escaping
    },
  });

export default i18n;

```
```
// src/App.js
import React from 'react';
import { useTranslation } from 'react-i18next';

const App = () => {
  const { t, i18n } = useTranslation();

  const changeLanguage = (lng) => {
    i18n.changeLanguage(lng); // Change the language
  };

  return (
    <div>
      <h1>{t('greeting')}</h1>
      <p>{t('welcome')}</p>
      <button onClick={() => changeLanguage('en')}>English</button>
      <button onClick={() => changeLanguage('fr')}>Français</button>
      <br />
      <button>{t('button.submit')}</button>
    </div>
  );
};

export default App;

```
# Hooks
## useState
- Allows you to add state to functional components.
## useEffect
- Manages side effects in your component (e.g., data fetching, subscriptions).
- You can specify dependencies to control when the effect runs.
- Can use Cleanup to close connection, ...
```
useEffect(() => {
  // Code to run on mount and when dependencies change
  return () => {
    // Cleanup code
  };
}, [dependencies]);

```
## useContext: 
- Allows you to access the value of a React context directly in a functional component.
```
const value = useContext(MyContext);
```
## useReducer
- An alternative to useState for managing complex state logic. It resembles Redux but works within a single component.
```
const [state, dispatch] = useReducer(reducer, initialState);
```
## UseCallback
- Returns a memoized version of a callback function, preventing unnecessary re-creations on re-renders.
```
const memoizedCallback = useCallback(() => {
  // Your callback logic
}, [dependencies]);

```
## UseMemo
- useMemo allows you to memoize expensive calculations and only re-compute them when specific dependencies change. This can prevent unnecessary re-renders of child components.
```
const computedValue = useMemo(() => {
  return expensiveCalculation(inputValue);
}, [inputValue]);
```
## useRef
- Returns a mutable ref object whose .current property can hold a value, commonly used to access DOM elements directly.
## React.memo  
- a higher-order component that memoizes the result of a functional component. It will only re-render the component if its props change.

## Detect changes
- each component can have its own state, managed through the useState hook (for functional components) or through this.setState (for class components). When you update the state using these methods, React know that a change has occurred.
- When you call the state update function (like setState or this.setState), React groups these updates together for performance reasons. It then schedules a re-render of the affected components.
- A reconciliation process that create a new virtual DOM and use a diffing algorithm to compare the new virtual DOM tree with the previous version.
- React performs a shallow comparison of the previous and current state (and props) to determine if an update is necessary
    - For primitive types (strings, numbers, booleans), React checks if the value has changed.
    - Reference Types: For objects and arrays, React checks if the reference has changed. If the reference to an object or array is the same, React assumes the contents have not changed and does not trigger a re-render.

# Context Redux
- State management can be challenging, especially when passing data from a parent component to multiple levels of child components.
- Choosing between Redux and the Context API depends on the specific needs of your application. Redux is more suitable for large applications with complex state management requirements, while the Context API is great for simpler scenarios where ease of use and less boilerplate are priorities. 
- for redux, components can subscribe to specific slices of the state using selectors. This means that a component will only re-render when the particular part of the state it is subscribed to changes. This targeted approach minimizes unnecessary re-renders. for context, when the context provider’s value updates, all components that consume that context will re-render.


-  Middleware acts as a bridge between the dispatching of an action and the moment it reaches the reducer, enabling you to extend Redux's capabilities, such as handling asynchronous actions, logging
  - Redux Thunk: Allows you to write action creators that return a function instead of an action. This function can perform async operations.
  - Redux Saga: Uses generator functions to handle side effects and async logic. It lets you manage complex flows like race conditions and retries.

- Redux flows
  - Action Creation: Actions are created to describe state changes.
  - Action Dispatching: Actions are dispatched to the store.
  - Reducer Processing: Reducers process the action and update the state.
  - State Update: The store updates its state with the new state returned by the reducers.
  - Component Update: Connected components re-render based on the updated state.


# Agile
- In Scrum, work is divided into time-boxed cycles called sprints, typically lasting 1-4 weeks. Each sprint starts with a Sprint Planning meeting where the team decides on a set of tasks, or user stories, to complete by the sprint's end.
- Daily Standup: A brief, daily meeting where team members discuss progress and obstacles.

# middle
- We can ask the product owner about the prioritization of current tasks to see if we can replace a new task with an existing one. 
- If not, I may ask about overtime to ensure we meet the deadline. After doing that, there’s a chance that we still can't keep the deadline due to the size of the task. 
- Therefore, I continously to communicate with the product owner to see if we can complete part of the task first, specifically the highest priority items.

# tech
- Identify Project Requirements, Research Available Technologies.
- Communicate with the customer to see if they have chosen a technology or to ask about the current technology they are using. This helps us recommend a solution that fits better with the customer’s system.
- If we need to recommend a new technology, I will inform them of the pros and cons, and a proof of concept (POC) would be the best case.
- Human resources are still very important. Is the team familiar with this technology, and how long will they need to become proficient in it?
- Another important factor is the project budget.


# Design
- functional requirements: ask about features
- non functional requirements:
  - how many users, rps, tps
  - peek load or nomal for distributed across all days
  - read/write ratio
- What is the expected scale of the system 
(e.g., number of users, data size, QPS)
- Are there any limitations 
in terms of technology, budget, or infrastructure?
- Is the data mostly read-heavy, write-heavy, or balanced


- estimation
- high level design APIs

draw

  - a pdf (200kb)
- high level design


# SOLID
- Single Responsibility Principle (SRP): A class should have only one reason to change. In other words, a class should have only one responsibility or job.

- Open/Closed Principle (OCP): Software entities (classes, modules, functions, etc.) should be open for extension but closed for modification .

- Liskov Substitution Principle (LSP):  In simpler terms, objects of a superclass should be replaceable with objects of its subclass without affecting the functionality of the program.

- Interface Segregation Principle (ISP):  This principle encourages the creation of fine-grained, client-specific interfaces rather than large, general-purpose interfaces.

- Dependency Inversion Principle (DIP): High-level modules should not depend on low-level modules. This principle encourages decoupling between modules by relying on abstractions (such as interfaces or abstract classes) rather than concrete implementations.

# Argocd
- Pros:
  - GitOps Model: Promotes a Git-centric approach to managing Kubernetes applications, allowing version control and easy rollback.
  - Declarative Configuration: Allows users to define application state in YAML files, making it easier to manage and track changes.
  - Automatic Syncing: Supports automated synchronization of the desired state from Git to the Kubernetes cluster, reducing manual intervention.
  - Multi-Cluster Support: Can manage applications across multiple Kubernetes clusters, providing flexibility in deployment.
  - User Interface: Offers a user-friendly web UI for monitoring and managing applications, improving visibility.
  - Integration: Easily integrates with other tools in the Kubernetes ecosystem, such as Helm, Kustomize, and various CI/CD systems.
- Cons:
  - Complexity: Initial setup and configuration can be complex, especially for users new to GitOps or Kubernetes.
  - Learning Curve: Requires familiarity with Git and Kubernetes concepts, which may be challenging for some teams.
  - Resource Consumption: Can consume additional resources in the cluster, which might be a concern in resource-constrained environments.
  - Limited Features: Some users find that it lacks certain features available in other CI/CD tools, such as advanced workflow management.
  - Dependency Management: Managing dependencies between applications can be complicated, especially in large, interdependent systems.