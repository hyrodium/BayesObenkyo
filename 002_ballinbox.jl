using Statistics
using Random
using Plots

abstract type ProbabilisticEvent end
abstract type ProbabilisticBox <: ProbabilisticEvent end
abstract type ProbabilisticBall <: ProbabilisticEvent end
struct BallRed <: ProbabilisticBall end
struct BallBlue <: ProbabilisticBall end
struct BoxWhite <: ProbabilisticBox end
struct BoxBlack <: ProbabilisticBox end
struct Conditional{A,B} <: ProbabilisticEvent where A <: ProbabilisticEvent where B <: ProbabilisticEvent
    a::A
    b::B
end
Base.:|(a::ProbabilisticEvent,b::ProbabilisticEvent)=Conditional(a,b)
struct Sequence <: ProbabilisticEvent
    s::Vector{<:ProbabilisticEvent}
end
iterate(s::Sequence) = iterate(s.s)

🔴 = BallRed()
🔵 = BallBlue()
⬜ = BoxWhite()
⬛ = BoxBlack()

P(::BoxWhite) = 2/5
P(::BoxBlack) = 3/5
P(::typeof(🔴|⬜)) = 2/3
P(::typeof(🔵|⬜)) = 1/3
P(::typeof(🔴|⬛)) = 2/3
P(::typeof(🔵|⬛)) = 1/3

P(🔴::ProbabilisticBall) = P(🔴|⬜)*P(⬜) + P(🔴|⬛)*P(⬛) # = P(🔴∩⬜) + P(🔴∩⬛)
P(s::Sequence) = prod(P.(s.s))
function P(c::Conditional{<:ProbabilisticBox,Sequence})
    box = c.a
    x = c.b
    return P(x|box)*P(box)/(P(x|⬜)*P(⬜)+P(x|⬛)*P(⬛))
end

Conditional(s::Sequence, box::ProbabilisticBox) = Sequence((x->x|box).(s.s))

P(🔴|⬜)
P(🔴)
P(🔵)
P(🔴)+P(🔵)

P(Sequence([🔴,🔵,🔵]))
P(🔴)*P(🔵)^2

P(Sequence([🔴,🔵,🔵])|⬜)
P(Sequence([🔴|⬜,🔵|⬜,🔵|⬜]))

for box in [⬜, ⬛]
    @eval function sampling(::typeof($box))
        rand() < P(🔴|$box) && return 🔴
        return 🔵
    end

    @eval function sampling(::typeof($box), n::Int)
        return Sequence([sampling($box) for _ in 1:n])
    end
end

function sampling()
    rand() < P(⬜) && return sampling(⬜)
    return sampling(⬛)
end

function sampling(n::Int)
    return Sequence([sampling() for _ in 1:n])
end

n = 10

x = sampling(⬜,n)
count(==(🔴), x.s) / n
count(==(🔵), x.s) / n
P(🔴|⬜)
P(🔵|⬜)
P(⬜|x)
P(⬛|x)

y = sampling(⬛,n)
count(==(🔴), y.s) / n
count(==(🔵), y.s) / n
P(🔴|⬛)
P(🔵|⬛)
P(⬜|y)
P(⬛|y)

z = sampling(n)
count(==(🔴), z.s) / n
count(==(🔵), z.s) / n
P(🔴)
P(🔵)
P(⬜|z)
P(⬛|z)


## 事前分布からの予測
function predict_sequence(p0, xⁿ)
    xs = xⁿ.s
    n = length(xs)
    ps = zeros(n+1)
    ps[1] = p0
    for i in 1:n
        ps[i+1] = P(xs[i]|⬜)*ps[i]/(P(xs[i]|⬜)*ps[i]+P(xs[i]|⬛)*(1-ps[i]))
    end
    
    return ps
end

xⁿ = sampling(⬜,50)
p0s = [(-x^3+3x+2)/4 for x in -1:0.001:1]
p0s = [(x+1)/2 for x in -1:0.05:1]
predict_sequences = [predict_sequence(p0, xⁿ) for p0 in p0s]
plot(predict_sequences, label=false)
