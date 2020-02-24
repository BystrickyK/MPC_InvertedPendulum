function B_res = columnMatrixRearrange(B, order)
%order = (xc alpha dxc dalpha)
%realOrder = (alpha dalpha xc dxc)
    B_tmp = B;
    [rows, cols] = size(B);
    
    B_res = B_tmp;
    for i = 1:rows
        B_res(i,:) = B_tmp(order(i), :);
    end
    
end