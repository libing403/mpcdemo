function UMs=calc_combine_unity(sumAMsk,lamda,Ns,sumQj)
    belta=1;
    J=1;
    UMs=sumAMsk+lamda*Ns+belta/J*sumQj;
end