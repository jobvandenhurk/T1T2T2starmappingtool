function [denominator, result] = neardiv(input,type,near)

if nargin == 1
vec = 2:input-1;
        ix = mod(input,vec);
        hits = find(ix==0);
        if isempty(hits) %prime
            denominator = input;
        else
            denominator = vec(max(hits));
        end
    
elseif nargin == 2
    if strcmp(type,'max')
        vec = 2:input-1;
        ix = mod(input,vec);
        hits = find(ix==0);
        if isempty(hits) %prime
            denominator = input;
        else
            denominator = vec(max(hits));
        end
        
    elseif strcmp(type,'min')
        vec = 2:input;
        ix = mod(input,vec);
        hits = find(ix==0);
        if isempty(hits) %prime
            denominator = input;
        else
            denominator = vec(min(hits));
        end
    else
        error('Invalid variable provided. Use min, max or near.');
    end
    
elseif nargin == 3
    if strcmp(type,'near')
        vec = 2:input;
        ix = mod(input,vec);
        hits = vec(find(ix==0));
        [~,t] = min(abs(hits-near));
        denominator = hits(t);
    end
end

result = input/denominator;
