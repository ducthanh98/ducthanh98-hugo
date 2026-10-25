---
title: "JavaScript, TypeScript & React Core Concepts"
date: 2024-01-20T10:00:00+07:00
draft: false
categories: ["Programming Languages"]
tags: ["JavaScript", "TypeScript", "React", "Frontend", "Event Loop"]
---

# JavaScript Fundamentals

## Closures
- A closure in JavaScript allows the function to remember the variables from the enclosing function where it was created, enabling encapsulation and state retention.

# Hoisting
- Hoisting in JavaScript is a behavior where variable and function declarations are moved to the top of their containing scope during the compile phase, before the code is executed. This means that you can use variables and functions before they are declared in the code.
- Variables declared with var are hoisted to the top of their function or global scope and initialized with undefined, but not initialized with **let, const** 

# Eventloop stack
- When a function is invoked, it gets added to the call stack. The JavaScript engine executes the function, and when it completes, it's removed from the stack.
- When asynchronous operations (like a setTimeout or an API call) are initiated, the JavaScript engine handles them and places the corresponding callback in the message queue once the operation is complete.
- The main thread continues executing other code without blocking for these operations.
- Once the call stack is empty (all synchronous code has executed), the event loop picks the next callback from the message queue and pushes it onto the call stack for execution.
- This continues until all messages in the queue have been processed and the stack is empty.


# Operator Type
- Union Types (|)
```
let value: number | string;
value = 42;         // Valid
value = "hello";    // Valid
```

- Intersection Types (&)
```
type A = { name: string };
type B = { age: number };

let person: A & B = {
  name: "John",
  age: 30,
};

```

- Pick creates a type by selecting specific properties from an existing type, while Omit creates a type by excluding specific properties.
```
type User = { name: string; age: number; email: string };
type UserWithoutEmail = Omit<User, "email">; // { name: string; age: number; }

```


# Interface, type
- Both interface and type can be used to define an object , but interface can be extended and merged, while type cannot. Use interface for object-oriented designs and type for more complex types, like unions and intersections.
# Decorator
- Decorators are special functions that modify classes, methods, or properties. They can be used to add metadata or modify behavior. They differ from regular functions because they are prefixed with @

# Redux vs context

- React Context and React Hooks are two powerful features of React that can help manage state and side effects in your application.



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

# Detect changes
- each component can have its own state, managed through the useState hook (for functional components) or through this.setState (for class components). When you update the state using these methods, React know that a change has occurred.
- When you call the state update function (like setState or this.setState), React groups these updates together for performance reasons. It then schedules a re-render of the affected components.
- A reconciliation process that create a new virtual DOM and use a diffing algorithm to compare the new virtual DOM tree with the previous version.
- React performs a shallow comparison of the previous and current state (and props) to determine if an update is necessary
    - For primitive types (strings, numbers, booleans), React checks if the value has changed.
    - Reference Types: For objects and arrays, React checks if the reference has changed. If the reference to an object or array is the same, React assumes the contents have not changed and does not trigger a re-render.

# Memoization
- Memoization is an optimization technique that involves caching the results of expensive function calls and returning the cached result
 when the same inputs occur again. In React, memoization helps avoid unnecessary calculations and re-renders.
-  React.memo is a higher-order component that wraps a functional component to memoize it. If the props of the component do not change, React skips rendering the component and uses the memoized version instead
- When to use
  - If you have components that are expensive to render 
  - Use React.memo when the component receives props that don’t change often
  - For functional components that simply render UI based on props 
  and don’t have internal state that affects rendering, React.memo is particularly useful.
- When Not to Use 
  - If a component is very simple and renders quickly
  - If a component’s props change frequently
  - Internal State Changes:

```
import React from 'react';

const MyComponent = React.memo(({ data }) => {
  // Expensive calculations or rendering logic
  return <div>{data}</div>;
});
```
# Lazy load
- You can use React.lazy to dynamically import components when they are needed. 
Combine this with Suspense to provide a fallback UI while the component is loading.
```
import React, { Suspense, lazy } from 'react';
import { BrowserRouter as Router, Route, Switch } from 'react-router-dom';

const Home = lazy(() => import('./Home'));
const About = lazy(() => import('./About'));

const App = () => (
  <Router>
    <Suspense fallback={<div>Loading...</div>}>
      <Switch>
        <Route path="/" exact component={Home} />
        <Route path="/about" component={About} />
      </Switch>
    </Suspense>
  </Router>
);

```

# React Lifecycle(#life-cycle)
In React, the component lifecycle can be divided into three main phases: Mounting, Updating, and Unmounting. 
Here’s a breakdown of each phase:

1. Mounting
When a component is being created and inserted into the DOM:

- constructor: Initializes state and binds methods.
static getDerivedStateFromProps: Syncs state with props before rendering.
- render: Renders the component to the DOM.
-componentDidMount: Invoked immediately after the component is mounted; ideal for API calls and subscriptions.
2. Updating
When a component is being re-rendered due to changes in props or state:

- shouldComponentUpdate: Allows control over whether a component should re-render.
- render: (same as above) Re-renders the component.
getSnapshotBeforeUpdate: Captures some information from the DOM (e.g., scroll position) before the updates are applied.
- componentDidUpdate: Invoked immediately after updating occurs; great for responding to prop or state changes.
3. Unmounting
When a component is being removed from the DOM:

componentWillUnmount: Cleanup tasks like cancelling network requests, removing subscriptions, etc.





Both React and Angular have lifecycle methods that allow developers to hook into the various stages of a component's existence, from creation to destruction. Here’s an overview of the lifecycle phases for both frameworks.


 # Angular Lifecycle
In Angular, components also have a lifecycle that consists of several phases. These phases are handled by lifecycle hooks, which are methods that you can implement in your components.


ngOnInit: Called once, after the first ngOnChanges. It is commonly used for initialization tasks, such as fetching data.

ngOnChanges: Called before ngOnInit and whenever one or more data-bound input properties change. This hook receives a SimpleChanges object containing the previous and current values.

ngDoCheck: Called during every change detection run. It allows for custom change detection.

ngAfterContentInit: Called after Angular has projected external content into the component.

ngAfterContentChecked: Called after the projected content has been checked.

ngAfterViewInit: Called after the component’s view (and child views) has been initialized.

ngAfterViewChecked: Called after the component’s view (and child views) has been checked.

ngOnDestroy: Called just before Angular destroys the component. This is where you can perform cleanup, like unsubscribing from observables or detaching event handlers.

---

# State Management: Redux vs Context API

- **Context API**: Built into React. Best for low-frequency, global state (e.g. current user theme, authenticated user profile, locale).
  - *Trade-off*: When a Context Provider's value updates, **all** consumer components re-render unless wrapped in granular providers or memoization.
- **Redux**: Dedicated state management library with a centralized store, strict unidirectional data flow, and immutable state updates.
  - *Advantage*: Components subscribe to specific slices of state using `useSelector`. Components only re-render when their selected slice changes, optimizing performance for large-scale applications.

## Redux Middleware: Thunk vs Saga
Middleware intercepts dispatched actions before they reach the reducer:
- **Redux Thunk**: Allows action creators to return a function `(dispatch, getState)` instead of a plain action object. Ideal for standard async calls (REST API requests).
- **Redux Saga**: Leverages ES6 Generator functions (`yield`, `takeEvery`, `call`, `put`) to manage complex async side effects, race conditions, debouncing, and retries.

## Redux Data Flow:
1. **Action Creation**: UI components dispatch an action describing the event: `{ type: 'cart/addItem', payload: item }`.
2. **Action Dispatching**: Action is dispatched to the centralized Redux store.
3. **Middleware**: Thunk/Saga handles async operations or logging if applicable.
4. **Reducer Processing**: Pure reducer functions take `(previousState, action)` and return a new state snapshot.
5. **Component Update**: Subscribed UI components re-render with the updated state slice.

---

# Internationalization (i18n) in React

Internationalization allows frontend applications to support multiple languages dynamically.

## Implementation with `react-i18next`

### 1. Configuration (`src/i18n.js`):
```javascript
import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';

const resources = {
  en: {
    translation: {
      greeting: "Hello, World!",
      welcome: "Welcome to our application!",
      button: { submit: "Submit" }
    }
  },
  vi: {
    translation: {
      greeting: "Xin chào!",
      welcome: "Chào mừng bạn đến với ứng dụng!",
      button: { submit: "Xác nhận" }
    }
  }
};

i18n
  .use(initReactI18next)
  .init({
    resources,
    lng: "vi",
    fallbackLng: "en",
    interpolation: { escapeValue: false }
  });

export default i18n;
```

### 2. Usage in Components (`src/App.js`):
```javascript
import React from 'react';
import { useTranslation } from 'react-i18next';

const App = () => {
  const { t, i18n } = useTranslation();

  const changeLanguage = (lng) => {
    i18n.changeLanguage(lng);
  };

  return (
    <div>
      <h1>{t('greeting')}</h1>
      <p>{t('welcome')}</p>
      <button onClick={() => changeLanguage('vi')}>Tiếng Việt</button>
      <button onClick={() => changeLanguage('en')}>English</button>
      <button>{t('button.submit')}</button>
    </div>
  );
};

export default App;
```




