function derv = Derivative(matrix,direction)
if numel(size(matrix)) > 2
    error('Max 2 dimensions!');
else
    if size(matrix,2) == 1
        matrix = matrix';
    end
    derv = zeros(size(matrix));
    derv(:,1) = [];
    if nargin == 1
        direction = 'forward';
    end
    
    if strcmp(direction,'backward')
        for n = size(matrix,2):-1:2
            derv(:,n-1) = matrix(:,n) - matrix(:,n-1);
        end
    else
        
        for n = 2:size(matrix,2)
            derv(:,n-1) = matrix(:,n) - matrix(:,n-1);
        end
    end
end