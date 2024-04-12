---
title: "Algorithms"
date: 2023-05-01T22:43:50+07:00
draft: true
---
# SOLID
- Single Responsibility Principle (SRP): A class should have only one reason to change. In other words, a class should have only one responsibility or job.

- Open/Closed Principle (OCP): Software entities (classes, modules, functions, etc.) should be open for extension but closed for modification .

- Liskov Substitution Principle (LSP):  In simpler terms, objects of a superclass should be replaceable with objects of its subclass without affecting the functionality of the program.

- Interface Segregation Principle (ISP):  This principle encourages the creation of fine-grained, client-specific interfaces rather than large, general-purpose interfaces.

- Dependency Inversion Principle (DIP): High-level modules should not depend on low-level modules. This principle encourages decoupling between modules by relying on abstractions (such as interfaces or abstract classes) rather than concrete implementations.

# Design pattern
## Creational patterns
### Factory Pattern:
- Factory Method is a creational design pattern that provides an interface for creating objects in a superclass, but allows subclasses to alter the type of objects that will be created which solves the problem of creating product objects without specifying their concrete classes.
- Pros:
    + avoid tight coupling between the creator and the concrete products
    + Single Responsibility Principle. You can move the product creation code into one place in the program, making the code easier to support.
    + Open/Closed Principle. You can introduce new types of products into the program without breaking existing client code.
- Cons:
    + The code may become more complicated since you need to introduce a lot of new subclasses to implement the pattern
```
type IGun interface {
    setName(name string)
    setPower(power int)
    getName() string
    getPower() int
}

type Ak47 struct {
    Gun
}

func newAk47() IGun {
    return &Ak47{
        Gun: Gun{
            name:  "AK47 gun",
            power: 4,
        },
    }
}

func getGun(gunType string) (IGun, error) {
    if gunType == "ak47" {
        return newAk47(), nil
    }
    return nil, fmt.Errorf("Wrong gun type passed")
}   
```

### Abstract Factory
- Abstract Factory patterns work around a super-factory which creates other factories. This factory is also called as factory of factories.
### Builder pattern
- Builder is a creational design pattern that lets you construct complex objects step by step. The pattern allows you to produce different types and representations of an object using the same construction code.
```
type IBuilder interface {
    setWindowType()
    setDoorType()
    setNumFloor()
    getHouse() House
}

func getBuilder(builderType string) IBuilder {
    if builderType == "normal" {
        return newNormalBuilder()
    }

    if builderType == "igloo" {
        return newIglooBuilder()
    }
    return nil
}

type NormalBuilder struct {
    windowType string
    doorType   string
    floor      int
}

func newNormalBuilder() *NormalBuilder {
    return &NormalBuilder{}
}

func (b *NormalBuilder) setWindowType() {
    b.windowType = "Wooden Window"
}

func (b *NormalBuilder) setDoorType() {
    b.doorType = "Wooden Door"
}

func (b *NormalBuilder) setNumFloor() {
    b.floor = 2
}

func (b *NormalBuilder) getHouse() House {
    return House{
        doorType:   b.doorType,
        windowType: b.windowType,
        floor:      b.floor,
    }
}


type IglooBuilder struct {
    windowType string
    doorType   string
    floor      int
}

func newIglooBuilder() *IglooBuilder {
    return &IglooBuilder{}
}

func (b *IglooBuilder) setWindowType() {
    b.windowType = "Snow Window"
}

func (b *IglooBuilder) setDoorType() {
    b.doorType = "Snow Door"
}

func (b *IglooBuilder) setNumFloor() {
    b.floor = 1
}

func (b *IglooBuilder) getHouse() House {
    return House{
        doorType:   b.doorType,
        windowType: b.windowType,
        floor:      b.floor,
    }
}


type House struct {
    windowType string
    doorType   string
    floor      int
}

type Director struct {
    builder IBuilder
}

func newDirector(b IBuilder) *Director {
    return &Director{
        builder: b,
    }
}

func (d *Director) setBuilder(b IBuilder) {
    d.builder = b
}

func (d *Director) buildHouse() House {
    d.builder.setDoorType()
    d.builder.setWindowType()
    d.builder.setNumFloor()
    return d.builder.getHouse()
}

import "fmt"

func main() {
    normalBuilder := getBuilder("normal")
    iglooBuilder := getBuilder("igloo")

    director := newDirector(normalBuilder)
    normalHouse := director.buildHouse()

    fmt.Printf("Normal House Door Type: %s\n", normalHouse.doorType)
    fmt.Printf("Normal House Window Type: %s\n", normalHouse.windowType)
    fmt.Printf("Normal House Num Floor: %d\n", normalHouse.floor)

    director.setBuilder(iglooBuilder)
    iglooHouse := director.buildHouse()

    fmt.Printf("\nIgloo House Door Type: %s\n", iglooHouse.doorType)
    fmt.Printf("Igloo House Window Type: %s\n", iglooHouse.windowType)
    fmt.Printf("Igloo House Num Floor: %d\n", iglooHouse.floor)

}
```
### Singleton
- is a creational design pattern that lets you ensure that a class has only one instance, while providing a global access point to this instance.
- Pros
    +  You can be sure that a class has only a single instance.
    + The singleton object is initialized only when it’s requested for the first time.
- Const
    + The pattern requires special treatment in a multithreaded environment so that multiple threads won’t create a singleton object several times.
```
var lock = &sync.Mutex{}

type single struct {
}

var singleInstance *single

func getInstance() *single {
    if singleInstance == nil {
        lock.Lock()
        defer lock.Unlock()
        if singleInstance == nil {
            fmt.Println("Creating single instance now.")
            singleInstance = &single{}
        } else {
            fmt.Println("Single instance already created.")
        }
    } else {
        fmt.Println("Single instance already created.")
    }

    return singleInstance
}
```

### Prototype
- Prototype is a creational design pattern that lets you copy existing objects without making your code dependent on their classes
```
type Inode interface {
    print(string)
    clone() Inode
}

type File struct {
    name string
}

func (f *File) print(indentation string) {
    fmt.Println(indentation + f.name)
}

func (f *File) clone() Inode {
    return &File{name: f.name + "_clone"}
}
```
## Structural patterns
### Decorator pattern
- structural design pattern that lets you attach new behaviors to objects by placing these objects inside special wrapper objects that contain the behaviors.
```
type TomatoTopping struct {
    pizza IPizza
}

func (c *TomatoTopping) getPrice() int {
    pizzaPrice := c.pizza.getPrice()
    return pizzaPrice + 7
}

type CheeseTopping struct {
    pizza IPizza
}

func (c *CheeseTopping) getPrice() int {
    pizzaPrice := c.pizza.getPrice()
    return pizzaPrice + 10
}
```
### Adapter pattern
- Adapter is a structural design pattern that allows objects with incompatible interfaces to collaborate.
```
type Computer interface {
    InsertIntoLightningPort()
}

type Mac struct {
}

func (m *Mac) InsertIntoLightningPort() {
    fmt.Println("Lightning connector is plugged into mac machine.")
}

type Windows struct{}

func (w *Windows) insertIntoUSBPort() {
    fmt.Println("USB connector is plugged into windows machine.")
}

type WindowsAdapter struct {
    windowMachine *Windows
}

func (w *WindowsAdapter) InsertIntoLightningPort() {
    fmt.Println("Adapter converts Lightning signal to USB.")
    w.windowMachine.insertIntoUSBPort()
}

```
## Behavioral Design pattern
### Command pattern
- a behavioral design pattern that turns a request into a stand-alone object that contains all information about the request. This transformation lets you pass requests as a method arguments, delay or queue a request’s execution, and support undoable operations.

### Strategy pattern
- Strategy is a behavioral design pattern that lets you define a family of algorithms, put each of them into a separate class, and make their objects interchangeable.
```
package main

type EvictionAlgo interface {
    evict(c *Cache)
}

type Fifo struct {
}

func (l *Fifo) evict(c *Cache) {
    fmt.Println("Evicting by fifo strtegy")
}


```
## Observer pattern
- Observer is a behavioral design pattern that lets you define a subscription mechanism to notify multiple objects about any events that happen to the object they’re observing.
```
type Subject interface {
    register(observer Observer)
    deregister(observer Observer)
    notifyAll()
}


```