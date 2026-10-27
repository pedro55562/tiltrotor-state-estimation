function [ S ] = SkewSymmetricMatrix( Vet )

S = [  0      -Vet(3)    Vet(2);
     Vet(3)      0      -Vet(1);
    -Vet(2)    Vet(1)         0];

end

