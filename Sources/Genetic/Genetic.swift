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
  private var previousRankingPool = [Chromosome<T>]()
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

    if self.previousRankingPool.count == ranking.count {
      let sorted = ranking.sorted(by: { $0.rank > $1.rank })
      let sortedPrevious = previousRankingPool.sorted(by: { $0.rank > $1.rank })
      var sortedCopy = sorted
      
      for i in 0..<sorted.count {
        let new = sorted[i]
        let old = sortedPrevious[i]
        sortedCopy[i] = old.rank <= new.rank ? new : old
      }
      self.rankingPool = sortedCopy
      
    } else {
      self.rankingPool = ranking
    }

    self.previousRankingPool = self.rankingPool
    
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
    
    guard matingPool.count > 1 else {
      return []
    }
        
    var crossoverResults: [[T]] = []
    
    for _ in 0..<n {
      let mom = matingPool[0].genome //first highest
      let dad = matingPool[1].genome //second highest
      
      //mate randomly
      var child: [T] = []
      for i in 0..<mom.count {
        let random = Int.random(in: 0...1)
        
        let randomMutation = Int.random(in: 0...mutationFactor)
        if randomMutation == 1 {
          child.append(mutationFunc())
        } else {
          child.append(random == 1 ? mom[i] : dad[i])
        }
      }
      crossoverResults.append(child)
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
  
  private func buildMatingPool() {
    matingPool = rankingPool.sorted(by: { $0.rank > $1.rank })
  }

}
