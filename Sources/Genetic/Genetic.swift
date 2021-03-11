import Foundation

public typealias Genome = Equatable

private struct Chromosome<T: Genome>: Equatable {
  var genome: [T]
  var rank: Double
}

public class Genetic<T: Genome> {
  
  public typealias FitnessFunction = (_ inValue: [T], _ index: Int) -> Double
  public typealias MutationFunction = () -> T

  public var generations = 0
  public var highestRanking: Double = 0.0
  public var startingPopulation: [[T]] = []

  /// A predefined function that is used to determine the rank of a specific offspring
  public var fitnessFunction: FitnessFunction?
  
  /// A predefined function that returns a value to be added to the child during a mutation event
  public var mutationFunction: MutationFunction?
  
  private var n = 10
  private var mutationFactor: Int = 100
  private var matingPool = [Chromosome<T>]()
  private var rankingPool = [Chromosome<T>]()
  private var population: [[T]] = []

  /// The default initializer for the Genetic class
  /// - Parameters:
  ///   - mutationFactor: A number greater than 0 that determines the chances of a single mutation. The probability is 1 / {this_number}
  ///   - numberOfChildren: Number of children per generation.
  public init(mutationFactor: Int = 100,
              numberOfChildren: Int = 10,
              startingPopulation: [[T]] = []) {
    self.n = numberOfChildren
    self.mutationFactor = mutationFactor
    self.startingPopulation = startingPopulation
  }
  
  /// Applies one generation of the genetic algorithm
  /// - Returns: The resulting population that was crossed over and mutated. To be used for next generation.
  public func apply() -> [[T]] {
    //get ranks for each member of the population
    if population.count == 0 {
      self.population = startingPopulation
    }
    
    var ranking: [Chromosome<T>] = []
    for i in 0..<population.count {
      let pop = population[i]
      let rank = self.getRank(value: pop, index: i)
      let chrome = Chromosome(genome: pop, rank: rank)
      ranking.append(chrome)
    }

    self.rankingPool = ranking
    
    self.buildMatingPool()
    
    generations += 1
    self.population = self.crossover()
    return self.population
  }
  
  /// Resets the generations and algorithm state
  public func clear() {
    self.generations = 0
    self.population.removeAll()
    self.matingPool.removeAll()
    self.rankingPool.removeAll()
  }
  
  /// Returns the current highest ranking offspring of the last generation
  /// - Returns: The highest ranking offspring
  public func highestRankingMember() -> [T] {
    return self.rankingPool.sorted(by: { $0.rank > $1.rank }).first?.genome ?? []
  }
  
  private func crossover() -> [[T]] {
    guard let mutationFunc = self.mutationFunction else {
      preconditionFailure("mutation function not defined")
    }
    
    guard matingPool.count > 0 else {
      return []
    }
    //split mating pool
    let batched = matingPool.halve()
    
    guard batched.count >= 2 else {
      return []
    }
    
    let left = batched[0].sorted(by: { $0.rank > $1.rank })
    let right = batched[1].sorted(by: { $0.rank > $1.rank })
    
    //cross over genomes
    var crossoverResults: [[T]] = []
    
    for i in 0..<left.count - 1 {
      let leftItem = left[i].genome
      let rightItem = right[i].genome
      
      let leftSplit = leftItem.halve()
      let rightSplit = rightItem.halve()
      
      var mother = rightSplit[0] + leftSplit[1]
      var father = leftSplit[0] + rightSplit[1]
      
      let randomMutation = Int.random(in: 0...mutationFactor)
      
      if randomMutation == 1 {
        let randomIndexM = Int.random(in: 0..<mother.count)
        let randomIndexF = Int.random(in: 0..<father.count)

        mother[randomIndexM] = mutationFunc()
        father[randomIndexF] = mutationFunc()
      }
      
      crossoverResults.append(mother)
      crossoverResults.append(father)
    }
        
    return crossoverResults
  }
  
  private func getRank(value: [T], index: Int) -> Double {
    guard let fitnessFunc = self.fitnessFunction else {
      preconditionFailure("fitness function not defined")
    }
    let rank = fitnessFunc(value, index)
    highestRanking = max(highestRanking, rank)
    return rank
  }
  
  private func getRankedElement() -> Chromosome<T>? {
    let randomizedPool = rankingPool.randomize()
  
    let randomHighFitness: Double = Double.random(in: 0...highestRanking)
    let rankable = randomizedPool.first(where: { randomHighFitness <= $0.rank })
    
    return rankable
  }
  
  private func buildMatingPool() {
    matingPool.removeAll()
    for _ in 0...n {
      if let chrome = self.getRankedElement() {
        matingPool.append(chrome)
      }
    }
  }

}
