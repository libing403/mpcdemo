function psnr=calc_degradation_psnr(degradation)
%根据figure5曲线，经过（1,37），（10,35）
psnr=-2/9*(degradation-1)+37;
end