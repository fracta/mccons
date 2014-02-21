#Unit tests for the NSGA_II module

require("NSGA_II")
using Base.Test


function test_nonDominatedCompare(n::Int, fitnessSize::Int)
  #exhaustive unit test
  tests = {}
  for i =1:n
    push!(tests, randomFitnessArray(fitnessSize))
  end
  function all_compare(x,y, op)
    #helper
    for i in zip(x,y)
      if !(op(i[1],i[2]))
	return false
      end
    end
    return true
  end
  for i in tests
    for j in tests
      v = nonDominatedCompare(i,j)
      if v == 1
	@test all_compare(i,j, >=) == true
      elseif v== -1
	@test all_compare(i,j, <=) == true
      end
    end
  end
  return true
end

function randomFitnessArray(fitnessLen::Int)
  #helper
  return map(abs, rand(Int16, fitnessLen))
end

function test_nonDominatedSort(cardinality::Int, fitnessLen::Int)
  #unit test
  #exhaustive
  pop = population(solution[], Dict{Vector, (Int, FloatingPoint)}())
  for i =  1: cardinality
    push!(pop.solutions, solution([],randomFitnessArray(fitnessLen)))
  end

  sorts = nonDominatedSort(pop)
  #no domination within the same front
  for i = 1:length(sorts)
    ar = sorts[i]
    for j in ar
      for k in ar
	@test nonDominatedCompare(pop.solutions[j].fitness, pop.solutions[k].fitness) == 0
      end
    end
  end
  #domination or equivalence of all for greater front
  #all in 1 dominate all in 2
  if(length(sorts)>1)
    for i = 1:length(sorts)-1
      a = sorts[i]
      b = sorts[i+1]
      for j in a
	for k in b
	  @test nonDominatedCompare(pop.solutions[j].fitness, pop.solutions[k].fitness) in (0,1)
	end
      end
    end
  end
    
  return true
end
  
  
function test_evaluateAgainstOthers(cardinality::Int, fitnessLen::Int, compare_method = nonDominatedCompare)
  #exhaustive unit test
  #generate the population
  pop = population(solution[], Dict{Vector, (Int, FloatingPoint)}())
  for i =  1: cardinality
    push!(pop.solutions, solution([],randomFitnessArray(fitnessLen)))
  end
  #evaluate all solutions
  result = {}
  for i = 1:cardinality
    push!(result, evaluateAgainstOthers(pop, i, compare_method))
  end
  #verify validity
  for i = 1:cardinality
    if !(isempty(result[i][3]))
      for j in result[i][3]
	@test compare_method(pop.solutions[result[i][1]].fitness, pop.solutions[j].fitness) == -1
      end
    end
  end
  
  return true
end

function slowDelete(values::Vector, deletion::Vector)
  #helper
  return filter(x->!(x in deletion), values)
end 

function generatePosRandInt(n::Int)
  #helper
  return filter(x->x>0, unique(sort(rand(Int16, n))))
end

function test_fastDelete(repet::Int, size::Int)
  #unit test, exhaustive
  for i= 1:repet
    values = generatePosRandInt(size)
    deletion = generatePosRandInt(size)
    @test slowDelete(values, deletion) == fastDelete(values, deletion)
  end
  return true
end









  
  
function test_all()
  #exhaustive
  test_nonDominatedCompare(1000,3)
  test_evaluateAgainstOthers(1000,5)
  test_fastDelete(2000,2000)
  test_nonDominatedSort(2000, 5)
  
  
  
  #non exhaustive
  return true
end

