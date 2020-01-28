function numVisSats = visSats(cutoff_angle,elevationMatrix)
numVisSats = zeros(287,1);
for r = 1:287
    numsats = 0;
    for p = 1:32
        if elevationMatrix(r,p)>cutoff_angle
            numsats = numsats + 1;
        end
    end
    numVisSats(r,1) = numsats;
end

end

