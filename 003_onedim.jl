using Plots
using Statistics
using Distributions
using LinearAlgebra
using StatsPlots
using GeometryBasics

N = 10^5

μ = 3
σ² = 4
λ = 1/σ²
xᴺ = μ .+ √σ² * randn(N)
x_dist = Distributions.Normal(μ, √σ²)
x_dist = Normal(μ, √σ²)
histogram(xᴺ, norm=true)
plot!(x_dist)

mean(xᴺ)
var(xᴺ)


## 平均のみ未知の場合
μ_μ = 4
σ²_μ = 8
λ_μ = 1/σ²_μ
dist_μ = Normal(μ_μ, √(σ²_μ))

nn = 35
plot(dist_μ, 0, 6)
for n in 1:nn
    xⁿ = xᴺ[1:n]
    λ_μ′ = n*λ + λ_μ
    μ_μ′ = (λ*sum(xⁿ) + λ_μ*μ_μ)/(n*λ + λ_μ)
    σ²_μ′ = 1/λ_μ′
    dist_μ′ = Normal(μ_μ′, √(σ²_μ′))
    plot!(dist_μ′, 0, 6)
end
plot!([μ], seriestype="vline")


## 分散のみ未知の場合
α_λ = 1
θ_λ = 1
dist_λ =  Gamma(α_λ,θ_λ)

nn = 100
plot(dist_λ,0,1)
for n in 1:10:nn
    xⁿ = xᴺ[1:n]
    α_λ′ = n/2 + α_λ
    θ_λ′ = 1/(dot(xⁿ.-μ, xⁿ.-μ)/2 + 1/θ_λ)
    dist_λ′ =  Gamma(α_λ′,θ_λ′)
    plot!(dist_λ′,0,1)
end
plot!([λ], seriestype="vline")


## 平均と分散の両方が未知の場合
# 事前分布
μ_μλ = 4
β_μλ = 2
α_μλ = 1
θ_μλ = 1

p(μ, λ) = pdf(Normal(μ_μλ, 1/√(β_μλ*λ)), μ) * pdf(Gamma(α_μλ,θ_μλ), λ)

# plot
_μ = 1:0.01:5
_λ = 0:0.01:2
contour(_μ, _λ, p)

# 更新
n = 10000
contour(_μ, _λ, p)
xⁿ = xᴺ[1:n]
β_μλ′ = n + β_μλ
μ_μλ′ = (sum(xⁿ) + β_μλ*μ_μλ)/(n + β_μλ)
α_μλ′ = n/2 + α_μλ
θ_μλ′ = 1/((dot(xⁿ, xⁿ) + β_μλ*μ_μλ^2 - β_μλ′*μ_μλ′^2)/2 + 1/θ_μλ)

q(μ, λ) = pdf(Normal(μ_μλ′, 1/√(β_μλ′*λ)), μ) * pdf(Gamma(α_μλ′,θ_μλ′), λ)

# plot
contour(_μ, _λ, q)
scatter!([Point(μ, λ)])
