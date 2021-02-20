import XCTest
@testable import Genetic

final class GeneticTests: XCTestCase {
  let confirm = [1, 2, 3, 4, 5, 6, 7, 8, 9]
  let numberOfChildren = 100
  private let rankingExponent = 2.0
  private var completed: Bool = false

  private lazy var gene: Genetic = {
    Genetic<[Int]>(mutationFactor: 20, numberOfChildren: numberOfChildren)
  }()
  
  func testExample() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct
    // results.
    // XCTAssertEqual(Genetic().text, "Hello, World!")
    
    gene.fitnessFunction = { (number: [Int]) -> Double in
      var result: Double = 0
      
      for i in 0..<number.count {
        let num = number[i]
        let correct = self.confirm[i]
        
        //let diff = abs(num - correct)
        if num == correct {
          result += 1
        }
      }
      
      if result == 0.0 {
        return 0.0
      }
      
      result = result / Double(self.confirm.count)
      result = pow(result, self.rankingExponent)
      
      if number == self.confirm {
        self.completed = true
      }
      return result
    }
    
    gene.mutationFunction = { () -> Int in
      return Int.random(in: 0...10)
    }
    
    var randomPop: [[Int]] = []

    for _ in 0..<numberOfChildren {
      var randomInternalPop: [Int] = []
      for _ in 0..<confirm.count {
        randomInternalPop.append(Int.random(in: 0...10))
      }
      randomPop.append(randomInternalPop)
    }

    var newPop = randomPop
    
    while !completed {
      newPop = gene.apply(population: newPop)
      print("\(Int(pow(gene.highestRanking, (1 / 2.0)) * 100.0))%")
    }
    
    XCTAssert(newPop.contains(self.confirm), "Could not find match")
  }
  
  static var allTests = [
    ("testExample", testExample),
  ]
}
