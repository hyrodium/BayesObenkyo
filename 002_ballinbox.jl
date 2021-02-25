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
P(::typeof(🔴|⬛)) = 1/4
P(::typeof(🔵|⬛)) = 3/4
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

y = sampling(⬛,n)
count(==(🔴), y.s) / n
count(==(🔵), y.s) / n
P(🔴|⬛)
P(🔵|⬛)

z = sampling(n)
count(==(🔴), z.s) / n
count(==(🔵), z.s) / n
P(🔴)
P(🔵)


P(⬜|x)
P(⬛|x)
