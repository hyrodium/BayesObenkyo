using Statistics
using Random

struct BernoulliDist
    μ::Float64
end

BernoulliDist(0.23)

function sampling(d::BernoulliDist)
    if rand() < d.μ
        return true
    else
        return false
    end
end

d = BernoulliDist(0.23)

N = 10000
mean([sampling(d) for _ in 1:N])
