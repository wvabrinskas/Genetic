# Genetic

![](https://img.shields.io/github/v/tag/wvabrinskas/Genetic?style=flat-square)
![](https://img.shields.io/github/license/wvabrinskas/Genetic?style=flat-square)
![](https://img.shields.io/badge/swift-5.2-orange?style=flat-square)
![](https://img.shields.io/badge/iOS-13+-darkcyan?style=flat-square)
![](https://img.shields.io/badge/macOS-10.15+-darkcyan?style=flat-square)
![](https://img.shields.io/badge/watchOS-6+-darkcyan?style=flat-square)
![](https://img.shields.io/badge/tvOS-13+-darkcyan?style=flat-square)

# Introduction
Genetic is a swift package that makes it incredibly simple to include the Genetic Algorithm within a project. 

# Usage
Genetic incredibly simple to use. You just create a `Genetic` object, set it fitness and mutation functions, set its starting population, call `apply()` and it will continue through to the next generation. 

```
  private var gene: Genetic = Genetic<Int>(mutationFactor: 10, numberOfChildren: 10, startingPopulation: [])
```
Defined: 
```
  public init(mutationFactor: Int = 100,
              numberOfChildren: Int = 10,
              startingPopulation: [[T]] = [])
```

- Genetic uses generic typing to build its population. `T` must conform to `Equatable`
- `mutationFactor` - A number greater than 0 that determines the chances of a single mutation. The probability is `1 / {this_number}`
- `numberOfChildren` - Number of children per generation.
- `startingPopulation` - An array of arrays that defines the first population to pass through the algorithm. 

## Properties

### Setting Starting population
You can set the starting population of the Genetic object. 
```
  gene.startingPopulation = newPop
```

### Fitness Function
Genetic has a property for defining the fitness function of the algorithm. This function should return a `Double` that ranks the child that is passed to this function. 

```
  gene.fitnessFunction = { (child: [Int], index: Int) -> Double in
    //return some rank as Doubleh
  }
```

### Mutation Function
Genetic has a property for defining the mutation function of the algorithm. This function should return `T`. This will be used to replace a portion of the child array when selected to mutate.

```
  gene.mutationFunction = { () -> Int in
    return Int.random(in: 0...10)
  }
```

## Metrics 
You can receive certain metrics from the Genetic object such as current generation and current highest rank.
```
  gene.generations
  gene.highestRanking
```

## Applying the algorithm 
You can nudge forward the algorithm by one generation by calling `apply()`. This will return the next generation. Genetic will store the most recent generation and calling this again will apply the algorithm to that generation, forwarding the alorithm along. 
```
  public func apply() -> [[T]]
```

## Clearing the algorithm
You can clear the whole algorithm and reset the class by calling `clear()`
```
public func clear()
```
- This will set the generations back to 0 and reset the working population (you will not have to reset the starting population)
