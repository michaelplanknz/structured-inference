function x = haltonSeq(i, b)
% Return the ith element of the 1D halton sequence in base b

f = 1;
x = 0;

while i > 0
    f = f/b;
    x = x+f*mod(i, b);
    i = floor(i/b);
end


