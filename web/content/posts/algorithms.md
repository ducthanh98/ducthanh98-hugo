---
title: "Algorithms"
date: 2023-05-01T22:43:50+07:00
draft: true
---
# Bitmanipulation
## Binary AND &
```
0 & 0 = 0
0 & 1 = 0
1 & 0 = 0
1 & 1 = 1

 Example: 5 & 7 => 0000101 & 0000111 = 0000101 => 5
```
## Binary OR |
```
0 | 0 = 0
0 | 1 = 1
1 | 0 = 1
1 | 1 = 1
```
## Binary XOR ^
```
0 ^ 0 = 0
0 ^ 1 = 1
1 ^ 0 = 1
1 ^ 1 = 0
```
## Binary NOT ~
```
~ 0 = 1
~ 1 = 0
```
## Binary LEFT SHIFT <<
```
a << b => a * power(2,b)
```

## Binary RIGHT SHIFT >>
```
a >> b => a / power(2,b)
```
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