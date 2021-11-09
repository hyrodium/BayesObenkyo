using Plots
using Statistics
using Distributions
using LinearAlgebra
using StatsPlots
using GeometryBasics

N = 10^4

μ = [1,2]
Σ = [1 0.3;0.3 2]
Λ = inv(Σ)
dist = MvNormal(μ, Σ)
xᴺ = rand(dist, N)

pts = [Point2(xᴺ[:,i]) for i in 1:N]

scatter(pts)


x = -2:0.01:5
y = -1:0.01:5
q(x,y) = pdf(dist, [x,y])
contour!(x, y, q)


## 平均のみ未知の場合
μ_μ = [0,0]
Σ_μ = [1 0;0 1]
Λ_μ = inv(Σ_μ)
dist_μ = MvNormal(μ_μ, Σ_μ)

x = -2:0.01:5
y = -1:0.01:5
q(x,y) = pdf(dist_μ, [x,y])
contour(x, y, q)
scatter!(Point2(μ))

n = 500
xⁿ = xᴺ[:,1:n]
Λ_μ′ = n*Λ + Λ_μ
μ_μ′ = (n*Λ + Λ_μ)\(Λ*vec(sum(xⁿ, dims=2)) + Λ_μ*μ_μ)
Σ_μ′ = inv(Λ_μ′)
dist_μ′ = MvNormal(μ_μ′, Σ_μ′)

x = -2:0.01:5
y = -1:0.01:5
q(x,y) = pdf(dist_μ′, [x,y])
contour(x, y, q)
scatter!(Point2(μ))

## 分散のみ未知の場合
ν_Σ = 2
W_Σ = [1 0;0 1]
dist_Σ = Wishart(ν_Σ, W_Σ)


# plot
plot()
for S in rand(dist_Σ,100)
    covellipse!([0,0], S, showaxes=true, label="cov2", n_std=2, aspect_ratio=1)
end
plot!()



n = 300

xⁿ = xᴺ[:,1:n]
ν_Σ′ = n + ν_Σ
W_Σ′ = inv((xⁿ.-μ)*(xⁿ.-μ)' + inv(W_Σ))
dist_Σ′ = Wishart(ν_Σ′, W_Σ′)

plot()
for S in rand(dist_Σ′,100)
    covellipse!([0,0], S, showaxes=true, label="cov2", n_std=2, aspect_ratio=1)
end
plot!()

covellipse([0,0], Λ, showaxes=true, label="cov2", n_std=2, aspect_ratio=1)


## 平均と分散の両方が未知の場合(TODO)
# 事前分布
μ_μλ = 4
β_μλ = 2
α_μλ = 1
θ_μλ = 1

p(μ, λ) = pdf(Normal(μ_μλ, 1/√(β_μλ*λ)), μ) * pdf(Gamma(α_μλ,θ_μλ), λ)+1

# plot
x = 1:0.01:5
y = 0:0.01:2
contour(x, y, p)

# 更新
n = 50
contour(x, y, p)
xⁿ = xᴺ[1:n]
β_μλ′ = n + β_μλ
μ_μλ′ = (sum(xⁿ) + β_μλ*μ_μλ)/(n + β_μλ)
α_μλ′ = n/2 + α_μλ
θ_μλ′ = 1/((dot(xⁿ, xⁿ) + β_μλ*μ_μλ^2 - β_μλ′*μ_μλ′^2)/2 + 1/θ_μλ)

q(μ, λ) = pdf(Normal(μ_μλ′, 1/√(β_μλ′*λ)), μ) * pdf(Gamma(α_μλ′,θ_μλ′), λ)

# plot
x = 1:0.01:5
y = 0:0.01:2
contour(x, y, q)
scatter!([Point(μ, λ)])
