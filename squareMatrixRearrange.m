function A_res = squareMatrixRearrange(A, order)
%order = (xc alpha dxc dalpha)
%realOrder = (alpha dalpha xc dxc)
    A_tmp = A;
    [rows, cols] = size(A);
    
    for i = 1:cols
        A_tmp(:, i) = A(:, order(i));
    end
    
    A_res = A_tmp;
    for i = 1:rows
        A_res(i,:) = A_tmp(order(i), :);
    end
    
end