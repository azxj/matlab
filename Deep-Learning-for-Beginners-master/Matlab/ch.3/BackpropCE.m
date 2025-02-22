% BackpropCE 函数基于随机梯度下降策略，使用反向传播算法，通过训练数据集对权重进行更新。
% 与前面不同的是，这里在输出层使用了 cross entropy 作为损失函数。
% 关于 cross entropy 的更多信息，可以参考 https://en.wikipedia.org/wiki/Cross_entropy。
%
% W1 为 4x3 矩阵，是输入层与隐藏层之间的权重参数。
% W2 为 1x4 矩阵，是隐藏层与输出层之间的权重参数。
% X 为 4x3 矩阵，包含所有训练样本的特征。
% D 为 4x1 矩阵（4 维向量），包含所有训练样本的标签。
%
% 该函数返回更新后的权重参数 W1 与 W2。
function [W1, W2] = BackpropCE(W1, W2, X, D)
  alpha = 0.9; % 学习率

  N = 4; % 训练数据的数量，亦即矩阵 X 的行数量
  for k = 1:N
    x = X(k, :)'; % 一个单独的训练样本的特征向量
                  % 注意这里进行了转置，将行向量转换为列向量
                  % 3 维向量
    d = D(k); % 该样本的标签
              % 标量

    v1 = W1*x; % 隐藏层的加权和
               % 4x1 矩阵（4 维向量）（[4x3] x [3x1] = [4x1]）
    y1 = Sigmoid(v1); % 隐藏层的激活值
                      % 4x1 矩阵（4 维向量）
    v  = W2*y1; % 输出层的加权和
                % 标量（[1x4] x [4x1] = [1x1]）
    y  = Sigmoid(v); % 输出层的激活值
                     % 标量

    e     = d - y; % 输出层的 e
                   % 标量
    delta = e; % 输出层的 delta
               % 这里由于同时使用了 sigmoid 激活函数和 cross entropy 损失函数，所以 delta = e，详见《Matlab Deep Learning》P75
               % 标量

    e1     = W2'*delta; % 隐藏层的 e
                        % 4x1 矩阵（4 维向量）（[1x4]' x [1x1] = [4x1]）
    delta1 = y1.*(1-y1).*e1; % 隐藏层的 delta，其中 y*(1-y) 是 sigmoid 函数的导数
                             % 4x1 矩阵（4 维向量）

    dW1 = alpha*delta1*x'; % 输入层-隐藏层权重参数的更新值
                           % 注意这里将 x 进行了转置，将列向量转换为行向量
                           % 4x3 矩阵（[4x1] x [3x1]' = [4x3]）
    W1 = W1 + dW1; % dW1 和 W1 的形状相同

    dW2 = alpha*delta*y1'; % 隐藏层-输出层权重参数的更新值
                           % 注意这里将 y1 进行了转置，将列向量转换为行向量
                           % 1x4 矩阵
    W2 = W2 + dW2; % dW2 和 W2 的形状相同
  end
end
