import Foundation

public typealias Genome = Equatable

private struct Chromosome<T: Genome>: Equatable {
  var genome: [T]
  var rank: Double
}

public class Genetic<T: Genome> {
  public typealias FitnessFunction = (_ inValue: [T]) -> Double
  public typealias MutationFunction = () -> T

  public var generations = 0
  public var highestRanking: Double = 0.0

  public var fitnessFunction: FitnessFunction?
  public var mutationFunction: MutationFunction?
  
  private var n = 10
  private var mutationFactor: Int = 100
  private var matingPool = [Chromosome<T>]()
  private var rankingPool = [Chromosome<T>]()

  public init(mutationFactor: Int = 100,
              numberOfChildren: Int = 10) {
    self.n = numberOfChildren
    self.mutationFactor = mutationFactor
  }
  
  public func apply(population: [[T]]) -> [[T]] {
    //get ranks for each member of the population
    self.rankingPool = population.map({ Chromosome(genome: $0,
                                                 rank: self.getRank(value: $0)) })
    self.buildMatingPool()
    
    generations += 1
    return self.crossover()
  }
  
  public func clear() {
    self.generations = 0
    self.matingPool.removeAll()
    self.rankingPool.removeAll()
  }
  
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
        let randomIndexM = Int.random(in: 0..<mother.count - 1)
        let randomIndexF = Int.random(in: 0..<father.count - 1)

        mother[randomIndexM] = mutationFunc()
        father[randomIndexF] = mutationFunc()
      }
      
      crossoverResults.append(mother)
      crossoverResults.append(father)
    }
        
    return crossoverResults
  }
  
  private func getRank(value: [T]) -> Double {
    guard let fitnessFunc = self.fitnessFunction else {
      preconditionFailure("fitness function not defined")
    }
    let rank = fitnessFunc(value)
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
    for _ in 1...n {
      if let chrome = self.getRankedElement() {
        matingPool.append(chrome)
      }
    }
  }

}
