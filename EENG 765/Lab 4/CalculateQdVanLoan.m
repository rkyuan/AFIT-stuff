function Q_d = CalculateQdVanLoan(F,G,Q,dt)
%
%   Q_d = CalculateQdVanLoan(F,G,Q,dt)

% From Brown and Hwang

NS = size(F,1);
NN = size(G,2);

Astar = [-F           G*Q*G';
        zeros(NS,NS)  F'] * dt;
Bstar = expm(Astar);

B12 = Bstar(1:NS,NS+1:2*NS);
B22 = Bstar(NS+1:2*NS, NS+1:2*NS);

Q_d = B22' * B12;
    
